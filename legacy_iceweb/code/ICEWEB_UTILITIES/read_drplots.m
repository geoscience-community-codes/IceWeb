function [drplots,ERROR_FLAG]=read_drplots(volcano);

% open pointer to volcano parameter file
[pv,ERROR_FLAG]=open_pointer_to_volcano(volcano);

if ERROR_FLAG==0

	% get drplots
	drplots=pfget_tbl(pv,'dr_plots');

	% test for existence
	if ~exist('drplots','var')
		drplots=[];
	end
else
	drplots=[];
end
