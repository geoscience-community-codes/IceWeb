function [pv,ERROR_FLAG]=open_pointer_to_volcano(volcano);

ERROR_FLAG=0;

% create pointer to iceweb parameter file
parameter_file_name=['/home/iceweb/PARAMETER_FILES/',volcano];
if exist([parameter_file_name,'.pf'])
	pv=dbpf(parameter_file_name);
else
	pv=-1;
	ERROR_FLAG=1;
	send_IceWeb_error(['Parameter file ',parameter_file_name,' does not exist']);
end
