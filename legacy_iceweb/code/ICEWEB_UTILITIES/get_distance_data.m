function [distances,DISTANCE_DATA_FOUND]=get_distance_data(volcano,stations)
% This function returns distance data for given volcano & set of stations
% This data is stored in one file per volcano

global ICEWEB TRUE FALSE;
DISTANCE=[ICEWEB,'/DATA/DISTANCE'];

numstations = length(stations);
distances = ones(numstations,1)*1000;

fname = [DISTANCE,'/',lower(volcano),'.ext'];
if exist(fname,'file')
	fin=fopen(fname,'r');
	line = fgetl(fin);
	i=0;
	while(length(line)==9),
		i=i+1;
		valid_stations{i}=deblank(line(1:4));
		valid_distances(i)=str2num(deblank(line(6:9)));
		line = fgetl(fin);
	end	
	fclose(fin);
	for i=1:numstations
		DISTANCE_DATA_FOUND(i)=FALSE;
		for c=1:length(valid_stations)
			if length(stations{i})==length(valid_stations{c})
				if stations{i}==valid_stations{c}
					distances(i)=valid_distances(c) *1000; % km to m
					DISTANCE_DATA_FOUND(i)=TRUE;
				end
			end
		end
		if DISTANCE_DATA_FOUND(i)==FALSE
			send_IceWeb_error(['No distance data for station ',stations{i},' in ',fname,' : Dr cannot be computed']);
		end
	end
else
	send_IceWeb_error(['No distance data for ',volcano,' in ',DISTANCE,' : Dr cannot be computed']);
	DISTANCE_DATA_FOUND=zeros(numstations,1);
end
