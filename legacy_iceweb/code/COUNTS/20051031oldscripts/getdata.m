function [dnum,counts]=getdata(fname,ndays);
% used for 'helicorder' file date formats, which are MMDDYY0000
%
% Based on getdata(fname,ndays), most likely written by Glenn Thompson
% documentation Updated by Celso Reyes July 24, 2003

global TEMP;

todaysDateNum = floor(now);
snum=todaysDateNum-ndays;

% look at last NDAYS rows of file
tempfile=[TEMP,'/tempwebheli.dat'];

%grab the last ndays of the volcano file, and put in a temp file
eval(['!tail -',num2str(ndays),' ',fname,' > ',tempfile]);

fid=fopen(tempfile,'r');

% read first date
datestamp=fscanf(fid,'%c',10);

% initilise arrays
y=[]; x=[];

% loop until end of 'shortened' file
while(length(datestamp)==10),
	yy=fscanf(fid,'%f',1);
	comments=fgetl(fid);
	if length(datestamp)==10
		yr=2000+str2num(datestamp(5:6));
		xx=datenum(yr,str2num(datestamp(1:2)),str2num(datestamp(3:4)));
		%disp([datestr(xx,1),' ',num2str(yy)]);
		if xx>snum
			y=[y yy]; x=[x xx];
		end
	end
	datestamp=fscanf(fid,'%c',10);
end

% close file
fclose(fid);

% make final array one entry per day - otherwise datetick.m screws up
dnum=snum:todaysDateNum; 
counts=zeros(length(dnum),1);
for c=1:numel(x)
	index=find(dnum==x(c));
	if ~isempty(index)
		counts(index)=y(c);
	end
end
