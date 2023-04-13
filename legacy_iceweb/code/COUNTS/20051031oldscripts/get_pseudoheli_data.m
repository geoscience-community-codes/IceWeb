function [dnum,counts]=get_pseudoheli_data(fname,ndays);
global TEMP;

snum=floor(now)-ndays;

% look at last NDAYS rows of file
tempfile=[TEMP,'/tempwebheli.dat'];
eval(['!tail -',num2str(ndays),' ',fname,' > ',tempfile]);
fid=fopen(tempfile,'r');

% read first date
datestamp=fscanf(fid,'%c',8);

% initilise arrays
y=[]; x=[];

% loop until end of 'shortened' file
while(length(datestamp)==8),
	yy=round(fscanf(fid,'%f',1));
	trash=fgetl(fid);
	xx=datenum(datestamp);
	if xx>snum
		y=[y yy]; x=[x xx];
	end
	datestamp=fscanf(fid,'%c',8);
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
