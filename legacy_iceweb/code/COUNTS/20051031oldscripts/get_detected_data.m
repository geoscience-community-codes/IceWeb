function [dnum,counts]=get_detected_data(fname,ndays);
% alternate version of getdata, used for compatability with 
% 'detected' file date formats, which are YYYYMMDD0000
%
% Based on getdata(fname,ndays), most likely written by Glenn Thompson
% Updated by Celso Reyes July 24, 2003

global TEMP;

snum=floor(now)-ndays;

% look at last NDAYS rows of file
tempfile=[TEMP,'/tempwebheli.dat'];
eval(['!tail -',num2str(ndays),' ',fname,' > ',tempfile]);
fid=fopen(tempfile,'r');

% read first date
datestamp=fscanf(fid,'%c',12);

% initilise arrays
y=[]; x=[];

% loop until end of 'shortened' file
while(length(datestamp)==12),
	yy=fscanf(fid,'%f',1);
	comments=fgetl(fid);
	if length(datestamp)==12
		yr=str2num(datestamp(1:4));
		xx=datenum(yr,str2num(datestamp(5:6)),str2num(datestamp(7:8)));
		%disp([datestr(xx,1),' ',num2str(yy)]);
		if xx>snum
			y=[y yy]; x=[x xx];
		end
	end
	datestamp=fscanf(fid,'%c',12);
end

% close file
fclose(fid);

% make final array one entry per day - otherwise datetick.m screws up
dnum=snum:floor(now);
counts=zeros(length(dnum),1);
for c=1:length(x)
	index=find(dnum==x(c));
	if ~isempty(index)
		counts(index)=y(c);
	end
end
