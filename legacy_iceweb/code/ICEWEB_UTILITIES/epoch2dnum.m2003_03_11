function [dnum] = epoch2dnum(epoch_time)
% Glenn Thompson, 1999
% Usage: dnum = epoch2dnum(epoch_time)
% Converts an epoch time to Matlab datenum format
% 
% dnum = epoch2dnum(0) returns UT now in Matlab datenum format

if epoch_time == 0
	epoch_time = mep2dep(now + (9 / 24));
end

yr=str2num(epoch2str(epoch_time,'%Y'));
mnth=str2num(epoch2str(epoch_time,'%m'));
dy=str2num(epoch2str(epoch_time,'%d'));
hr=str2num(epoch2str(epoch_time,'%H'));
mnte=str2num(epoch2str(epoch_time,'%M'));
scnd=str2num(epoch2str(epoch_time,'%S'));

dnum = datenum(yr,mnth,dy,hr,mnte,scnd);
