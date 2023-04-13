function [data,DATA_FOUND]=load_spec_data(yr,mn,dy,station);
global TRUE FALSE ICEWEB;

SPEC_DATA=[ICEWEB,'/DATA/SPEC'];

filename=station;
fullpath=[SPEC_DATA,'/',yr,'/',mn,'/',dy,'/',filename,'.log'];
if ~exist(fullpath,'file')
	date_str=[yr,mn,dy];
	filename=[station,'_',date_str];
	fullpath=['/home/glenn/ICEWEB/SSAM/',date_str,'/',filename,'.log'];
end
if exist(fullpath,'file')
	disp(fullpath);
	% update flag
	DATA_FOUND=TRUE;
	% load data
	eval(['load ',fullpath]);
	eval(['data = ',filename,';']);
else
	data=[];
	DATA_FOUND=FALSE;
	disp(['create_UTday_spectrograms: ',fullpath,' does not exist']);
end

