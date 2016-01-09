function rtrun_tremorwrapper(queue_num, runtimematfile)
disp(mfilename)
if ~exist('runtimematfile', 'var')
    runtimematfile = getenv('RUNTIMEMATFILE');
end
disp(sprintf('%%%%%%%%%%%%%%%%%%%\nqueue: %d\nruntimematfile: %s', queue_num, runtimematfile))
set(0, 'DefaultFigureVisible', 'off');

debug.set_debug(12);
while 1
	logbenchmark('rtrun_tremorwrapper', 0);
	tremor_wrapper(sprintf('waveform_files/queue%d',queue_num), runtimematfile);
	disp('************** PROBABLE CRASH ***********');
	pause(60);
end
