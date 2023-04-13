function drs_20s(volcano,snum,enum)
% Glenn Thompson, April 1999
% Usage: create_av20s_plot(volcano,snum,enum)
% 
% Input Arguments: 
% volcano 	- name of volcano
% snum		- start date/time in Matlab datenum format
% enum 		- end   date/time in Matlab datenum format
% 
% Example:
% create_av20s_plot('Shishaldin',datenum(1999,4,18),datenum(1999,4,20))
% this will something resembling a reduced displacement plot for
% Shishaldin between 18 April 1999 and 20 April 1999. 
%
% The data plotted are 20 second aervages of seismic amplitude corrected
% for distance and instrument response. All dates are Universal time.
%
% This function is part of the IceWeb system. 

% no warnings
warning off

close all;

wavelength=1000; %m/s based on 2 Hz peak and 2000 m/s.

% read set of stations for each volcano from controlfile
[numstations,stations,windstation]=read_volcano_record(volcano);

% get distance data
[distances]=get_distance_data(volcano,stations,numstations);

disp(' ');
disp(['Current IceWeb stations for ',volcano,' are:']);
disp(stations);

disp(' ');
choice=input('Do you want to plot all these stations (y/n) ? ','s');
if choice=='n'
	disp(' ');
	numstations=input('Enter number of stations you want to plot  ? ');
	numstations=min(numstations,5);
	disp(' ');
	disp('Enter station-ids for stations you want plotting: ');
	stations={};
	for c=1:numstations
		stations{c}=input(['Enter station id ',num2str(c),' ? '],'s');
	end
	disp(['The following stations will be plotted:']);
	disp(stations);
end


% loop over all stations in controlfile for this volcano
for c=numstations:-1:1
	sta=stations{c};
	l2=0;

	% Load transfer function for this station & distance from volcano summit
	instrument_response_file=[RESPONSE,'/',sta,'.ext'];

	if exist(instrument_response_file,'file')==2
		eval(['load ',instrument_response_file]);
		eval(['instr_resp = ',sta,'* 1000;']);  % counts/m
correction_factor=10000*sqrt(distances(c)).*sqrt(wavelength)/instr_resp(8);


		% loop over all specified days
		for dnum=floor(snum):floor(enum)
			% get day, month & year
			% this is used for filenames
			yr=num2str(year(dnum));
			mnth=num2str(month(dnum));
			if length(mnth) < 2
				mnth=['0',mnth];
			end
			dy=num2str(day(dnum));
			if length(dy) < 2
				dy=['0',dy];
			end
	
			% fetch MeanSquare data for this station & this day
			date_str=[yr,mnth,dy];
			fullpath=[MEAN_SQUARE,'/',date_str,'/',sta,'.ext'];
			file_exists=exist(fullpath,'file');
			if file_exists==2 
				eval(['load ',fullpath]);
				eval(['data = ',sta,';']);
				if size(data)~=[0 0]
					ms=data(:,1);
					timestamp=data(:,2);
				end
				l1=length(ms);
				drs(l2+1:l2+l1,c)=sqrt(ms(1:l1))*correction_factor;
				tstamp(l2+1:l2+l1,c)=timestamp(1:l1);
				l2=l2+l1;
			end
	
		end % loop over days
	else
		disp('no transfer function');
	end	

end % loop over stations

%if numstations < 5
%	for counter=numstations+1:5
%		temp=zeros(size(drs,1),1);
%		drs(:,counter)=temp;
%		tstamp(:,counter)=temp;
%	end
%end
	
%if (now-enum) >2
%	semilogy(tstamp(:,5),drs(:,5),'c.',tstamp(:,4),drs(:,4),'m.',tstamp(:,3),drs(:,3),'g.', ...
%	tstamp(:,2),drs(:,2),'r.',tstamp(:,1),drs(:,1),'b.');
%else
%	semilogy(tstamp(:,5),drs(:,5),'c.',tstamp(:,4),drs(:,4),'m.',tstamp(:,3),drs(:,3),'g.', ...
%	tstamp(:,2),drs(:,2),'r.',tstamp(:,1),drs(:,1),'b.');
%end

		
%a=axis;
%axis([snum enum 1 100]);
%grid;
%if (enum-snum) < 1.8
%	datetick('x',15);
%else
%	datetick('x',7);
%end
%ylabel(['Reduced Displacement (cm^2)']);
%xlabel(['UT date/time']);
%title(['Reduced displacement plot for ',volcano,' starting on ',datestr(snum,1)]);
% Add legend
%legend_str=[stations{numstations},blanks(4-length(stations{1}))];
%for c=1:numstations-1
%	legend_str=[legend_str;stations{numstations-c},blanks(4-length(stations{numstations-c}))];
%end
%legend(legend_str,0);

%figure
l=length(drs);
for c=1:l
	avdrs(c,1)=mean([drs(c,:)]);
	avt(c,1)=mean([tstamp(c,:)]);
end
x=[avt avdrs];
sort(x,1);
plot(x(:,1),x(:,2));
a=axis;
axis([snum enum 0 a(4)]);
grid
datetick('x',15);
xlabel('UT Time');
ylabel('Dr (cm^2)');



