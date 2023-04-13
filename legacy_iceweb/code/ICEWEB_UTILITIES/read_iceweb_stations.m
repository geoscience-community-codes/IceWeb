function [web_stations,pss,ERROR_FLAG]=read_iceweb_stations(volcano);

% open pointer to volcano parameter file
[pv,ERROR_FLAG]=open_pointer_to_volcano(volcano);

if ERROR_FLAG==0

	% get Web stations for this volcano from parameter file
	pss=pfget_arr(pv,'stations');
	web_stations=pfkeys(pss)

else
	pss=-1;
	web_stations={};
end
