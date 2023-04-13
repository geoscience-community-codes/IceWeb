function spectrogram_request(volcano,snum,enum);

% set other important variables
F=0.5:0.1:15.0;  % this is frequency range of archived SSAM data

% use which stations?
[stations,numstations]=stations_to_use(volcano);

% enter time resolution in hours
disp(' ');
disp('Enter time resolution in hours - larger values are quicker to plot');
hours_av=input('Enter time resolution in hours  ? ');

% work out step size
step_size=hours_av*6; % 24 means 4 hours - thats 180 per month

% open a new figure
figure;
	

for frame_num=1:numstations
	% define useful variables
	station_num=numstations+1-frame_num;
	station=stations{station_num};
	for dnum=snum:enum
		[T1,A1]=load_and_av_spec_data(station,dnum,step_size);
		if ~isempty(T1) 
			if exist('T2','var')
				T2=[T2;T1];
				A2=[A2;A1];
			else
				T2=T1; A2=A1;
			end
		end
	end
	if exist('A2','var')
		if ~isempty(A2)
			% calculate position of spectrogram & trace data frames for this station
			[spectrogram_position,trace_position]=...
			calculate_frame_positions(numstations,frame_num,0.9);
			% plot data
			plot_spectrogram(A2',F,T2,station,frame_num,...
			spectrogram_position,[],['']);
		end
	end
	clear A2 T2;
end
tstr=sprintf('%s %s',volcano,datestr(dnum,1));
title(tstr,'Color',[0 0 0],'FontSize',[16], 'FontWeight',['bold']');
add_colorbar;
orient tall;


function [T_av,A_av]=load_and_av_spec_data(station,dnum,step_size);
TRUE=1;

% load spectral data for this day
[yr,mn,dy]=yyyymmdd(dnum);
[data,DATA_FOUND]=load_spec_data(yr,mn,dy,station);

if DATA_FOUND == TRUE & size(data)~=[0 0]
	l=size(data,1);
	T=data(:,1);
	A=data(:,2:147);
			
	if step_size == 1
		T_av=T;
		A_av=A;
	else % average the signal
		i=1;
		first_sample=(i-1)*step_size+1;	
		last_sample=i*step_size;
		while (last_sample <= l),
			T_av(i,1)=nanmean(T(first_sample:last_sample));
			for f_bin=1:146
				A_av(i,f_bin)=nanmean( ...
				A(first_sample:last_sample,f_bin));
			end
			i=i+1;
			first_sample=(i-1)*step_size+1;
			last_sample=i*step_size;
		end
	end
else	
	T_av=[];A_av=[];
end


steps_per_day=144/step_size;	
dT=1/steps_per_day;
if size(T_av,1)<steps_per_day
	A_av(steps_per_day,146)=0;
	T_av=(dnum:dT:dnum+1-dT)';
end

