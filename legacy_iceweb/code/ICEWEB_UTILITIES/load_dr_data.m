function [x,y,DATA_FOUND]=load_dr_data(volcano,station,snum,enum);
% Usage: [wt,wind,NO_WIND_DATA]=grabwinddata(snum,enum,windstation)
% Glenn Thompson, 1999
% This function grabs wind data for the given windstation for the
% time interval described by snum and enum
% station = 3 or 4 character station id 
% snum - start UT time/date in Matlab datenumber format
% enum - end   UT time/date in Matlab datenumber format
%
% x - time vector for dr data
% y - dr data
% DATA_FOUND - if this is FALSE, then no dr data was found

global ICEWEB TRUE FALSE;

DR_DATA=[ICEWEB,'/DATA/DR'];

% initialise variables
y=[];x=[];
DATA_FOUND=FALSE;

cnum=snum;
while (cnum<=enum),
	[yr,mn,dy]=yyyymmdd(cnum);
	dirname=[DR_DATA,'/',yr,'/',mn,'/',dy,'/',volcano];
	if exist(dirname,'dir')~=7
		dirname=['/home/glenn/ICEWEB/DR/',datestr(cnum,1)];
	end
	if exist(dirname,'dir')==7		
		l=length(y);
		fname=[dirname,'/',station,'.log'];
		if exist(fname,'file')
			eval(['load ',fname]);
			eval(['newdata =',station,';']);
			if ~isempty(newdata)
				l2=length(newdata);
				y(l+1:l+l2)=newdata(:,1);
				x(l+1:l+l2)=newdata(:,2);
				DATA_FOUND=TRUE;
			end
		end	
	end
	cnum=cnum+1;
end


if DATA_FOUND
	% sort by time just in case digitisers screwed up!
	[x,y]=sort_rows(x,y);

	% clip data to lie between snum & enum
	[x,y]=clip_data(x,y,snum,enum);
else
	send_IceWeb_error(['No dr data found for ',station,' between ',datestr(snum,1),' and ',datestr(enum,1)]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x,y]=sort_rows(x,y);
dummy1=[x' y'];
dummy2=sortrows(dummy1,1);
x=dummy2(:,1);
y=dummy2(:,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dnum,drs]=clip_data(x,y,snum,enum);

l=length(x);
dnum=[];drs=[];

% clip data to just that required
first=1;
while (x(first)<snum) & (first<l),
	first=first+1;
end

last=first; 
while (x(last)<enum & last<l),
	last=last+1;
end
	
if first==l
	drs(1:l)=y(1:l);
	dnum(1:l)=x(1:l);
else
	drs(1:last+1-first)=y(first:last);
	dnum(1:last+1-first)=x(first:last);
end

