function [windstation,ERROR_FLAG]=read_windstation(volcano);

% open pointer to volcano parameter file
[pv,ERROR_FLAG]=open_pointer_to_volcano(volcano);

if ERROR_FLAG==0

	% get windstation
	windstation=pfget_string(pv,'windstation');

else

	windstation=[];
end
