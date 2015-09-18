function iceweb(ds, varargin)

    % Process arguments
    [thismode, snum, enum, nummins, delaymins, thissubnet, matfile] = matlab_extensions.process_options(varargin, 'mode', 'archive', 'snum', 0, 'enum', 0, 'nummins', 10, 'delaymins', 0, 'subnet', '', 'matfile', 'pf/tremor_runtime.mat');
    if exist(matfile, 'file')
        load(matfile);
        PARAMS.mode = thismode;
        clear thismode;
    else
        disp('matfile not found')
        return
    end

    % subset on thissubnet
    if ~strcmp(thissubnet, '') 
        index = 0;
        for c=1:length(subnets)
            if strcmp(subnets(c).name, thissubnet)
                index = c;
            end
        end
        if index > 0
            subnets = subnets(index);
            debug.print_debug(0, 'subnet found')
        else
            debug.print_debug(0, 'subnet not found')
            return;
        end
    end

    % end time
    if enum==0
        enum = utnow - delaymins/1440;
    end
    
    % since the standard way is to create Antelope databases from day-long
    % miniseed files for each channeltag, and reference these from
    % day-long databases, I could add a check here using
    % listMiniSEEDfiles to see if there are any data files for each day
    % before I look for each 10 minute window for that day with
    % waveform_wrapper
    %   steps:
        % check if datasource is Antelope
        % loop over each day from snum to enum
        % call listMiniSEEDfiles
        % see for which channeltag I get exists=2, and then only use that
        % list of successful channeltags for that day
        % create timewindows for that day
        % call iceweb_helper for each time window
        
    % NEW STUFF TO IMPLEMENT ABOVE SUGGESTION - MIGHT NOT WORK    
    if exist('ds','var') & strcmp(get(ds,'type'),'antelope')

        for c=1:numel(subnets)
            sites = subnets(c).sites
            for dnum = floor(snum):ceil(enum)
                
                for ccc=1:numel(sites)
                    disp(sites(ccc).channeltag.string())
                end
                
%                 todaysites = get_channeltags_active(sites, snum); % subset to channeltags valid
        disp('SCAFFOLD')         
todaysites = sites;
chantag = [todaysites.channeltag];
%                 for ccc=1:numel(todaysites)
%                     disp(sites(ccc).channeltag.string())
%                 end             
                % change channel tag if this is MV network because channels in wfdisc table
                % are like SHZ_--
                for cc=1:numel(chantag)
                    if strcmp(chantag(cc).network, 'MV')
                        chantag(cc).channel = sprintf('%s_--',chantag(cc).channel);
                    end
                end
                
                m = listMiniseedFiles(ds, chantag, dnum, dnum+1);
                {m.filepath}
                [m.exists]
                %todaysites = todaysites([m.exists]==2);
                tw = get_timewindow(min([enum dnum+1]), nummins, max([dnum snum]));

                newsubnets = subnets(c);
                newsubnets.sites = todaysites;
                for ccc=1:numel(todaysites)
                    disp(sites(ccc).channeltag.string())
                end
                
                % loop over timewindows backwards, thereby prioritizing most recent data
                for count = length(tw.start) : -1 : 1
                    thistw.start = tw.start(count);	
                    thistw.stop = tw.stop(count);	
                    iceweb_helper(paths, PARAMS, newsubnets, thistw, ds);
                end
            end
        end
    else
        % THE WAY WE USED TO DO IT
        % timewindows
        if snum==0
            tw = get_timewindow(enum, nummins);
        else
            tw = get_timewindow(enum, nummins, snum);
        end
        snum = enum - nummins/1440;

        % loop over timewindows backwards, thereby prioritizing most recent data
        for count = length(tw.start) : -1 : 1
            thistw.start = tw.start(count);	
            thistw.stop = tw.stop(count);	
            iceweb_helper(paths, PARAMS, subnets, thistw);
        end
    end

end


function iceweb_helper(paths, PARAMS, subnets, tw, ds)
    debug.printfunctionstack('>');

    highpassfilterobject = filterobject('h', 0.5, 2);
    makeSamFiles = false;
    makeSoundFiles = true; 

    if ~exist('ds','var')
        for c=1:numel(PARAMS.datasource)
            if strcmp(PARAMS.datasource(c).type, 'antelope')
                ds(c) = datasource(PARAMS.datasource(c).type, PARAMS.datasource(c).path);
%                 ds(c) = datasource('antelope', ...
%                '/raid/data/MONTSERRAT/antelope/db/db%04d%02d%02d',...
%                'year','month','day');
            else
                ds(c) = datasource(PARAMS.datasource(c).type, PARAMS.datasource(c).path, str2num(PARAMS.datasource(c).port));
            end
        end
    end
    %gismo_datasource = gismo_datasource(1);

    %% LOOP OVER SUBNETS / SITES
    for subnet_num=1:length(subnets)
        % which subnet?
        subnet = subnets(subnet_num).name;

        % get IceWeb sites
        sites = subnets(subnet_num).sites;
        if isempty(sites)
            continue;
        end

        % loop over all elements of tw
        for twcount = 1:length(tw.start)

            snum = tw.start(twcount);
            enum = tw.stop(twcount);

            % Have we already process this timewindow?
            tenminspfile = getSgram10minName(paths,subnet,enum);
%             if exist(tenminspfile, 'file')
%                 fprintf('%s already exists - skipping\n',tenminspfile);
%                 continue
%             end
            
            %% Get waveform data
            debug.print_debug(0, sprintf('%s %s: Getting waveforms for %s from %s to %s at %s',mfilename, datestr(utnow), subnet , datestr(snum), datestr(enum)));
            w = waveform_wrapper([sites.channeltag], snum, enum, ds);

            %% PRE_PROCESS DATA
            
            % Eliminate empty waveform objects
            w = removeempty(w);
            if numel(w)==0
                debug.print_debug(0, 'No waveform data returned - skipping');
                continue
            end

            % Clean the waveforms
            %w = clean(w); % this doesn't work. i don't seem to have access
            %to w.data and i don't understand what Celso has done with
            %diff(false, nans) etc., so let us make this easy
            w = detrend(w);

            % Apply calibs
            w = apply_calib(w, sites);

            % Apply high pass filter to broadband signals
            w = highpass(w);
            
            %% PLOT WAVEFORMS
            close all
            mulplt(w)
            %s = input('continue?');
            [spdir,spbase,spext] = fileparts(tenminspfile);
            tenminmulplt = fullfile(spdir, sprintf('mulplt_%s%s',spbase,spext));
            orient tall;
            saveImageFile(tenminmulplt, 72);         
            

            %% PLOT SPECTROGRAM	sometimes spectralobject.specgram fails if data are poor
            %try
                close all
                debug.print_debug(1, sprintf('Creating %s',tenminspfile))
                specgram_iceweb(PARAMS.spectralobject, w, 0.75, extended_spectralobject_colormap);
                %specgram_wrapper(PARAMS.spectralobject, w, 0.75, extended_spectralobject_colormap);

                %% SAVE SPECTROGRAM PLOT TO IMAGE FILE AND CREATE THUMBNAIL
                orient tall;
            
                if saveImageFile(tenminspfile, 72)

                    fileinfo = dir(tenminspfile); % getting a weird Index exceeds matrix dimensions error here.
                    debug.print_debug(0, sprintf('%s %s: spectrogram PNG size is %d',mfilename, datestr(utnow), fileinfo.bytes));	

                    % make thumbnails
                    makespectrogramthumbnails(tenminspfile);

                end
                close all

            
                %% SOUND FILES
                if makeSoundFiles
                    % 20120221 Added a "sound file" like 201202211259.sound which simply records order of stachans in waveform object so
                    % php script can match spectrogram panel with appropriate wav file 
                    % 20121101 GTHO COmment: Could replace use of bnameroot below with strrep, since it is just used to change file extensions
                    % e.g. strrep(tenminspfile, '.png', sprintf('_%s_%s.wav', sta, chan)) 
                    [bname, dname, bnameroot, bnameext] = matlab_extensions.basename(tenminspfile);
                    fsound = fopen(sprintf('%s%s%s.sound', dname, filesep, bnameroot),'a');
                    for c=1:length(w)
                        soundfilename = fullfile(dname, sprintf('%s_%s_%s.wav',bnameroot, get(w(c),'station'), get(w(c), 'channel')  ) );
                        fprintf(fsound,'%s\n', soundfilename);  
                        debug.print_debug(0, sprintf('Writing to %s',soundfilename)); 
                        data = get(w(c),'data');
                        m = max(data);
                        if m == 0
                            m = 1;
                        end 
                        data = data / m;
                        wavwrite(data, get(w(c), 'freq') * 120, soundfilename);
                    end
                    fclose(fsound);
                end

                %% COMPUTE SAM DATA
                if makeSamFiles
                    tic;
                    % Calculate and save true ground motion data (at the
                    % seismometer) to file (no reduced measurements)
                    try
                        stats = waveform2stats(w, 1/60);  
                        %stats = waveform2f(w);
                    catch	
                        debug.print_debug(0, 'waveform2stats failed');
                    end

                    for c = 1:length(stats)
                        samcollection = stats(c);
                        %measurements = {'Vmax';'Vmedian';'Vmean';'Dmax';'Dmedian';'Dmean';'Drms';'Energy';'peakf';'meanf'};
                        measurements = {'Vmax';'Vmedian';'Vmean';'Dmax';'Dmedian';'Dmean';'Drms';'Energy';'peakf';'meanf'};
                        for m = 1:length(measurements)
                            measure = measurements{m};	 
                            if isfield(samcollection, measure)
                                eval(sprintf('s = samcollection.%s;',measure));
                                if isempty(s)
                                    debug.print_debug(2, sprintf('SAM object for %s is blank',measure));
                                else
                                    debug.print_debug(3, sprintf('Calling save2bob for %s', measure));
                                    try
                                        save2bob(s.station, s.channel, s.dnum, s.data, measure);
                                    catch
                                        debug.print_debug(0, sprintf('save2bob failed for %s-%s',s.station, s.channel));
                                    end
                                end
                            else
                                debug.print_debug(2, sprintf('measure %s not found',measure));
                            end
                        end
                    end

                end
            %end
            
            %%
        end
    end

    debug.printfunctionstack('<');
end


function goodsites = get_channeltags_active(sites, snum)
    k=0;
    goodsites = [];
    for c=1:numel(sites)
        if sites(c).ondnum <= snum-1 && sites(c).offdnum >= snum
            k = k + 1;
            goodsites(k) = sites(c);
            disp(sprintf('Keeping %s',sites(c).channeltag.string()));
%             sites(c).ondnum
%             sites(c).offdnum
%             snum
        else
            disp(sprintf('Rejecting %s',sites(c).channeltag.string()));
%             sites(c).ondnum
%             sites(c).offdnum
%             snum
        end
    end

end
	
function w = apply_calib(w, sites)
    % ADD RESPONSE FROM SUBNETS TO WAVEFORM OBJECTS
    
    % get a cell array like {'MV.MBRY..BHZ';'MV.MBLG..SHZ'; ...} from
    % sites.channeltag
    for c=1:numel(sites)
        chantagcell{c} = string(sites(c).channeltag);
    end
    
    for c=1:numel(w)
        % get the channeltag for this waveform
        wchantag = string(get(w,'channeltag'));
        j = strmatch(wchantag, chantagcell); % this is the index of the matching channeltag in sites
        if length(j)==1
            calib = sites(j).calib;
            addfield(w(c), 'calib', calib);
            calibunits = sites(j).units;
            if strcmp(get(w(c),'Units'), 'Counts')
                fprintf('%s: Applying calib of %d for %s.%s\n',mfilename, resp.calib, thissta, thischan);
                if (calib ~= 0)
                    w(c) = w(c) * calib;
                    w(c) = set(w(c), 'units', calibunits);
                    %w(c) = set(w(c), 'units', 'nm / sec');
                end
                %fprintf('%s: Max corrected amplitude for %s.%s = %e nm/s\n',mfilename: thissta, thischan, rawmax);
            end
        end
    end
end

function w = highpass(w)
    for c=1:numel(w)
        
        thissta = get(w(c), 'station');
        thischan = get(w(c), 'channel');

		if strfind(thischan,'BH') | strfind(thischan, 'HH') | strfind(thischan, 'BD')
			try
                debug.print_debug(1, sprintf('Applying high pass filter to %s.%s', thissta, thischan));
				w(c) = filtfilt(highpassfilterobject, w(c));
			catch
                debug.print_debug(1, sprintf('Filter failed'));
			end
        end
        
    end
end



function stats = waveform2stats(w, newFs)
    stats=[];
    for c=1:length(w)
        oldFs = get(w(c), 'freq');
        compression_factor = round(oldFs / newFs);
        if strcmp(get(w(c), 'units'), 'nm / sec')
            stats(c).Vmax = makestat(w(c), 'absmax', compression_factor);
            stats(c).Vmedian = makestat(w(c), 'absmedian', compression_factor);
            stats(c).Vmean = makestat(w(c), 'absmean', compression_factor);
            %e = energy(s); 
            %stats.Energy = e.resample('absmean', compression_factor);, 
            w(c) = integrate(w(c));
        end

        if strcmp(get(w(c), 'units'), 'nm')
            stats(c).Dmax = makestat(w(c), 'absmax', compression_factor);
            stats(c).Dmedian = makestat(w(c), 'absmedian', compression_factor);
            stats(c).Dmean = makestat(w(c),'absmean', compression_factor);
            stats(c).Drms = makestat(w(c), 'rms', compression_factor);
        end
    end
end

function s=makestat(w, method, compression_factor)
	try % rare error in waveform/resample
        	wr = resample(w, method, compression_factor);
        	s = waveform2sam(wr);
        	s.measure = method;
	catch
		s = [];
	end
end


function stats = waveform2f(w)
    w = waveform_addsgram(w);
    for c=1:length(w)
        sgram = get(w(c), 'sgram');
        if isstruct(sgram)
            % downsample sgram data to 1 minute bins
            [Smax,i] = max(sgram.S);
            peakf = sgram.F(i);
            meanf = (sgram.F' * sgram.S)./sum(sgram.S);
            dnum = unique(floorminute(sgram.T/86400));
            for k=1:length(dnum)
                p = find(floorminute(sgram.T) == dnum(k));
                stats(c).peakf(k) = nanmean(peakf(p));
                stats(c).meanf(k) = nanmean(meanf(p));       
            end
        else
            sgram
        end
    end
end

