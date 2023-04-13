function [d,s,f]=plot_iceworm_data_for_station(station,num_mins)
% Usage [d,s,f]=plot_iceworm_data_for_station(station,num_mins)
% Plots and returns last few minutes of iceworm data for 'EHZ' channel of given station
% num_mins = number of minutes of data you want to see
% can use this for checking if Iceworm data are coming through
%
% Glenn Thompson, October 1999
TRUE=1;
%end_time = str2epoch('now');
end_time = mep2dep(now);
start_time = end_time - num_mins * 60;
[d,s,f]=get_iceworm_data_for_station(station,'EHZ',start_time,end_time);
if f==TRUE
	figure;
	l=length(d);
	t=(1:length(d))/s/60;
	plot(t,d);
	xlabel('time (mins)');
	ylabel('counts');
	disp(['data points found ',num2str(l)]);
	disp(['sample rate is ',num2str(s),' Hz']);
	disp(['first ten data samples are:']);
	d(1:10)
else
	disp(['got no data']);
end

