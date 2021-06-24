function rtrun_loadwaveforms(varargin)
startup_tremor;
[snum, delaymins, RUNTIMEMATFILE] = matlab_extensions.process_options(varargin, 'snum', 0, 'delaymins', 0, 'RUNTIMEMATFILE', getenv('RUNTIMEMATFILE'));
debug.set_debug(3);
while 1
	logbenchmark(mfilename, 0);
	if (snum>0)
		tremor_loadwaveformdata('snum', snum, 'delaymins', delaymins, 'RUNTIMEMATFILE', RUNTIMEMATFILE);
	else
		tremor_loadwaveformdata('delaymins', delaymins, 'RUNTIMEMATFILE', RUNTIMEMATFILE);
	end
	disp(sprintf('Waiting %s',datestr(utnow,30)));
	pause(60);
end
