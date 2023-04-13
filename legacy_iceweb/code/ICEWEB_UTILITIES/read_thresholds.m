function [thresholds,use,ERROR_FLAG]=read_thresholds(volcano);

% read stations & pointer to stations
[web_stations,pss,ERROR_FLAG]=read_iceweb_stations(volcano);	

if ERROR_FLAG==0

	% loop over each station
	for station_num=1:length(web_stations)
		ps=pfget_arr(pss,web_stations{station_num});
		thresholds(station_num)=pfget_num(ps,'threshold');
		use(station_num)=pfget_string(ps,'use');
	end
else
	thresholds=[];use=[];
end
