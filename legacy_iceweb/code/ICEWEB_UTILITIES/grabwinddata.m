function [wt,wind,NO_WIND_DATA]=grabwinddata(snum,enum,windstation);
% Usage: [wt,wind,NO_WIND_DATA]=grabwinddata(snum,enum,windstation)
% Glenn Thompson, 1999
% This function grabs wind data for the given windstation for the
% time interval described by snum and enum
% windstation - weatherstation to grab wind data for, e.g. 'cbwind' for Cold Bay 
% snum - start UT time/date in Matlab datenumber format
% enum - end   UT time/date in Matlab datenumber format
%
% wt - time vector for wind data
% wind - wind speed vector for wind data
% NO_WIND_DATA - if this is TRUE, then no wind data was found

global ICEWEB TRUE FALSE;
WIND_DATA=[ICEWEB,'/DATA/WIND'];

cnum=snum;
wt=[];wind=[];
NO_WIND_DATA=TRUE;

while (cnum<enum),
	[cyr,cmon]=yyyymmdd(cnum);
	fname=[windstation,'_',cyr,cmon];
	fullpath=[WIND_DATA,'/',fname];
	if exist(fullpath,'file')
		disp([fname,' FOUND']);
		eval(['load ',WIND_DATA,'/',fname]);
		eval(['newdata =',fname,';']);
		if ~isempty(newdata)
			NO_WIND_DATA = FALSE;
			l1=length(wt);
			newwt=newdata(:,1);
			newwind=newdata(:,2);
			l2=length(newwt);
			wt(l1+1:l1+l2)=newwt(1:l2);
			wind(l1+1:l1+l2)=newwind(1:l2);
		end
	end
	cnum=datenum(str2num(cyr),str2num(cmon)+1,1);
end

l=length(wt);
if NO_WIND_DATA==FALSE
	first=1;
	while (wt(first)<snum),
		first=first+1;
	end

	last=first;
	while (wt(last)<enum & last<l),
		last=last+1;
	end

	wt=wt(first:last);
	wind=wind(first:last);
end



