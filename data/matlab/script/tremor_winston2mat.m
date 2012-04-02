function tremor_winston2mat(subnets, tw)
global paths PARAMS
WINSTON_DATASOURCE(1) = datasource('winston', 'churchill.giseis.alaska.edu', 16022);
%WINSTON_DATASOURCE(2) = datasource('winston', 'humpy.giseis.alaska.edu', 16022);
WINSTON_DATASOURCE(2) = datasource('winston', 'pubavo1.wr.usgs.gov', 16022);
print_debug(sprintf('> %s',mfilename),1)

%%%%%%%%%%%%%%%%% LOOP OVER SUBNETS / STATIONS
% loop over all subnets
for subnet_num=1:length(subnets)
	% which subnet?
	subnet = subnets(subnet_num).name;

	% get IceWeb stations
	station = subnets(subnet_num).stations;
    	scnl = station2scnl(station, 'AV');

	% loop over all elements of tw
	for twcount = 1:length(tw.start)
		tic;
		snum = tw.start(twcount);
		enum = tw.stop(twcount);

		% Have we already process this timewindow?
		tenminspfile = getSgram10minName(subnet,enum);
		diaryname = getSgramDiaryName(subnet, enum);
		diary(diaryname);
		disp(sprintf('%s %s: Started',mfilename, datestr(utnow)));

		if strcmp(PARAMS.mode, 'realtime')
			% need to check for spectrogram file too
			if exist(tenminspfile,'file')
				% go to next timewindow because the spectrogram PNG exists
				disp(sprintf('%s %s: Data already processed because spectrogram file %s already exists. Skipping',mfilename, datestr(utnow), tenminspfile));
				diary off;
				continue;	
			else
				% 20111213: Create a zero size spectrogram image, so we know there was an attempt to run IceWeb on this timewindow
				system(sprintf('touch %s',tenminspfile)); 
				disp(sprintf('%s %s: Created 0 length spectrogram file %s',mfilename, datestr(utnow), tenminspfile));
			end
		end

		% Get waveform data
		disp(sprintf('%s %s: Getting waveforms for %s from %s to %s at %s',mfilename, datestr(utnow), subnet , datestr(snum), datestr(enum)));
		w = getwinstonwaveforms(scnl, snum, enum, WINSTON_DATASOURCE);

		% Did we get any data - if not, delete spectrogram file so it will try again later, and quit loop.	
		if isempty(w)
			disp(sprintf('%s %s: No waveform data found - skipping',mfilename, datestr(utnow)));
			delete(tenminspfile)
			diary off;
			break;
		end

		% If we are requesting real-time data, wait for data to backfill because there may be latency.
		% Otherwise, ignore this condition.
		if (utnow - snum) < (10/1440) % real-time data were requested
			 
			% Did we get enough data - if not, delete spectrogram file so it will try again later, and quit loop.
			secsRequested = (enum - snum) * 86400;
			minFraction = 0.99;
			[wsnum, wenum] = gettimerange(w);
			secsGot = (max(wenum) - min(wsnum)) * 86400;
 			if (secsGot/secsRequested) < minFraction
				fprintf('%s %s: Only got %.1f seconds of data - skipping\n',mfilename,datestr(utnow),secsGot);	
				disp('Insufficient waveform data found');
				delete(tenminspfile)
				diary off;
				break;
			end
		end

		% Save waveform data
		save2waveformmat(w, 'waveform_files/loaded', snum, enum, subnet);

		% update benchmark log
		logbenchmark(mfilename, toc);
		
		disp(sprintf('%s %s: Finished',mfilename, datestr(utnow)));
		diary off

	end
end
print_debug(sprintf('< %s',mfilename),1)
