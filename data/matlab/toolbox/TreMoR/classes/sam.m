classdef sam 
% SAM Seismic Amplitude Measurement class constructor, version 1.0.
%
% SAM is a generic term used here to represent any continuous data
% sampled at a regular time interval (usually 1 minute). This is a 
% format widely used within the USGS Volcano Hazards Programme which
% originally stems from the RSAM system (Endo & Murray, 1989)
%
% Written for loading and plotting RSAM data at the Montserrat Volcano 
% Observatory (MVO), and then similar measurements derived from the VME 
% "ltamon" program and ampengfft and rbuffer2bsam which took Seisan 
% waveform files as input. 
%
% RSAM data are historically stored in "BOB" format, which consists
% of a 4 byte floating number for each minute of the year, for a 
% single station-channel.
%
% s = sam() creates an empty SAM object.
%
% s = sam('file', ) creates a SAM object from a vector of datenum's
% and a corresponding vector of data.
%
% s = sam(sta, chan, snum, enum, measure, datadir) can be used
% to read BOB files and create a SAM object directly.
%
% s = sam('file', file, 'snum', snum, 'enum', enum, 'sta', sta, 'chan', chan, 'measure', measure, 'seismogram_type', seismogram_type, 'units', units)
%
% s = sam('file', file, 'snum', snum, 'enum', enum) can be used
% to read BOB files and create a SAM object directly.
%
%     file        % the path to the file. Substitutions enabled
%                 'SSSS' replaced with sta
%                 'CCC' replaced with chan
%                 'MMMM' replaced with measure
%                 'YYYY' replaced with year (from snum:enum)
%                 These allow looping over many year files
%     snum        % the start datenum
%     enum        % the end   datenum
%     sta         % station
%     chan        % channel
%     measure     % statistical measure, default is 'mean'
%     seismogram_type % e.g. 'velocity' or 'displacement', default is 'raw'
%     units       % units to label y-axis, e.g. 'nm/s' or 'nm' or 'cm2', default is 'counts'
%
% Examples:
%     s = sam('file', fullfile(MVO_DATA, 'RSAM_1', 'SSSSYYYY.DAT'), datenum(1996,1,1), datenum(1996, 2, 1), 'sta', 'MGHZ')
% This is the same as:
%     s = sam('file', fullfile(MVO_DATA, 'RSAM_1', 'MGHZ1996.DAT'), datenum(1996,1,1), datenum(1996, 2, 1))
% But the first can load over multiple years, e.g.:
%     s = sam('file', fullfile(MVO_DATA, 'RSAM_1', 'SSSSYYYY.DAT'), datenum(1996,1,1), datenum(2000, 6, 13), 'sta', 'MGHZ')
            
%
% METHODS:
% --------
%
% Filtering the data: 
%   RESAMPLE:
%   DOWNSAMPLE: (possibly obsolete, use RESAMPLE).
%   CORRECT:
%   DESPIKE:
%   REMOVE_CALIBS
%   REDUCE:
%
% Plots:
%   PLOT:
%   PLOTYY:
%
% Input & output files:
%   toTextFile:
%   save:
%   load:
%
% To other types of object:
%   SAM2ENERGY:
%
% % ------- DESCRIPTION OF FIELDS IN SAM OBJECT ------------------
%   DNUM:   a vector of MATLAB datenum's
%   DATA:   a vector of data (same size as DNUM)
%   MEASURE:    a string describing the statistic used to compute the
%               data, e.g. "mean", "max", "std", "rms", "meanf", "peakf",
%               "energy"
%   SEISMOGRAM_TYPE: a string describing whether the SAM data were computed
%                    from "raw" seismogram, "velocity", "displacement"
%   REDUCED:    a structure that is set is data are "reduced", i.e. corrected
%               for geometric spreading (and possibly attenuation)
%               Has 4 fields:
%                   REDUCED.Q = the value of Q used to reduce the data
%                   (Inf by default, which indicates no attenuation)
%                   REDUCED.SOURCELAT = the latitude used for reducing the data
%                   REDUCED.SOURCELON = the longitude used for reducing the data
%                   REDUCED.STATIONLAT = the station latitude
%                   REDUCED.STATIONLON = the station longitude
%                   REDUCED.DISTANCE = the distance between source and
%                   station in km
%                   REDUCED.WAVETYPE = the wave type (body or surface)
%                   assumed
%                   REDUCED.F = the frequency used for surface waves
%                   REDUCED.WAVESPEED = the S wave speed
%                   REDUCED.ISREDUCED = True if the data are reduced
%   UNITS:  the units of the data, e.g. nm / sec.
%   USE: use this sam object in plots?
%   FILES: structure of files data is loaded from

% AUTHOR: Glenn Thompson, Montserrat Volcano Observatory
% $Date: $
% $Revision: $

    properties(Access = public)
        dnum = [];
        data = [];
        measure = 'mean';
        seismogram_type = 'raw';
        reduced = struct('Q', Inf, 'sourcelat', NaN, 'sourcelon', NaN, 'distance', NaN, 'waveType', '', 'isReduced', false, 'f', NaN, 'waveSpeed', NaN, 'stationlat', NaN, 'stationlon', NaN); 
        units = 'counts';
        use = true;
        files = '';
        sta = ''
        chan = ''
        snum = -Inf;
        enum = Inf;
    end
    
    methods(Access = public)

        function self=sam(varargin)
            
            
            [file, self.snum, self.enum, self.sta, self.chan, self.measure, self.seismogram_type, self.units] = ...
                matlab_extensions.process_options(varargin, 'file', '', 'snum', self.snum, 'enum', self.enum, 'sta', self.sta, ...
                'chan', self.chan, 'measure', self.measure, 'seismogram_type', self.seismogram_type, 'units', self.units);
            
            %%%% CREATING SAM OBJECT FROM A BOB FILE            
            % check if filename has a year in it, if it does
            % make sure snum doesn't start before this year
            % and enum doesn't end after this year
            if ~isempty(file)
                dummy = regexp(file, '(\d+)', 'match');
                if ~isempty(dummy)
                    yyyy = str2num(dummy{end});
                    d=datevec(now);yearnow=d(1);clear d
                    if yyyy>=1980 & yyyy<=yearnow
                        self.snum = max([self.snum datenum(yyyy,1,1)]);
                        self.enum = min([self.enum datenum(yyyy,12,31,23,59,59)]);
                    end
                end

                % Generate a list of files
                self = findfiles(self, file);

                % Load the data
                for f = self.files
                    if f.found
                        self = self.load(f);
                    end
                end
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
        function self = findfiles(self, file)
            % Generate a list of files corresponding to the file pattern,
            % snum and enum given.

            filenum = 0;

            % substitute for station
            file = regexprep(file, 'SSSS', self.sta);
            
            % substitute for channel
            file = regexprep(file, 'CCC', self.chan);
            
            % substitute for measure
            file = regexprep(file, 'MMMM', self.measure);             

            % set start year and month, and end year and month
            [syyy sm]=datevec(self.snum);
            [eyyy em]=datevec(self.enum);
           
            for yyyy=syyy:eyyy
                
                filenum = filenum + 1;
                files(filenum) = struct('file', file, 'snum', self.snum, 'enum', self.enum, 'found', false);
    
                % Check year against start year 
                if yyyy~=syyy
                    % if not the first year, start on 1st Jan
                    files(filenum).snum = datenum(yyyy,1,1);
                end
   
                % Check year against end year
                if yyyy~=eyyy
                    % if not the last year, end at 31st Dec
                    files(filenum).enum = datenum(yyyy,12,31,23,59,59);
                end   
   
                % Substitute for year        
                files(filenum).file = regexprep(files(filenum).file, 'YYYY', sprintf('%04d',yyyy) );
                fprintf('Looking for file: %s',files(filenum).file);
  
                if exist(files(filenum).file, 'file')
                    files(filenum).found = true;
                    fprintf(' - found\n');
                else
                    fprintf(' - not found\n');
                end
            end
            self.files = files;
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
        function self = load(self, f)
        % Purpose:
        %    Loads derived data from a binary file in the BOB RSAM format
        %    The pointer position at which to reading from the binary file is determined from f.snum 
        %    Load all the data from f.snum to f.enum. So if timewindow is 12:34:56 to 12:44:56, 
        %    it is the samples at 12:35, ..., 12:44 - i.e. 10 of them. 
        %    
        % Input:
        %    f - a structure which contains 'file', 'snum', 'enum' and 'found' parameters
        % Author:
        %   Glenn Thompson, MVO, 2000

            % initialise return variables
            datafound=false;
            dnum=[];
            data=[];

            [yyyy mm]=datevec(f.snum);
            days=365;
            if mod(yyyy,4)==0
                days=366;
            end

            datapointsperday = 1440;
            headersamples = 0;
            tz=0;
            if strfind(f.file,'RSAM')
                headersamples=datapointsperday;
                tz=-4;
            end
            startsample = ceil( (f.snum-datenum(yyyy,1,1))*datapointsperday)+headersamples;
            endsample   = (f.enum-datenum(yyyy,1,1)) *datapointsperday + headersamples;
            %endsample   = floor( max([ datenum(yyyy,12,31,23,59,59) f.enum-datenum(yyyy,1,1) ]) *datapointsperday);
            nsamples    = endsample - startsample + 1;

            % create dnum & blank data vector
            dnum = matlab_extensions.ceilminute(f.snum)+(0:nsamples-1)/datapointsperday - tz/24;
            data(1:length(dnum))=NaN;
            
            if f.found    
                % file found
                debug.print_debug(sprintf( 'Loading data from %s, position %d to %d of %d', ...
                     f.file, startsample,(startsample+nsamples-1),(datapointsperday*days) ),3); 
   
                fid=fopen(f.file,'r', 'l'); % big-endian for Sun, little-endian for PC

                % Position the pointer
                offset=(startsample)*4;
                fseek(fid,offset,'bof');
   
                % Read the data
                [data,numlines] = fread(fid, nsamples, 'float32');
                fclose(fid);
                debug.print_debug(sprintf('mean of data loaded is %e',nanmean(data)),1);
   
                % Transpose to give same dimensions as dnum
                data=data';

                % Test for Nulls
                if length(find(data>0)) > 0
                    datafound=true;
                end    
            end
            
            % Now paste together the matrices
            self.dnum = matlab_extensions.catmatrices(dnum, self.dnum);
            self.data = matlab_extensions.catmatrices(data, self.data);

            if ~datafound
                debug.print_debug(sprintf('%s: No data loaded from file %s',mfilename,f.file),1);
            end

            % eliminate any data outside range asked for - MAKE THIS A
            % SEPARATE FN IF AT ALL
            i = find(self.dnum >= self.snum & self.dnum <= self.enum);
            self.dnum = self.dnum(i);
            self.data = self.data(i);
            
            % Fill NULL values with NaN
            i = find(self.data == -998);
            self.data(i) = NaN;
            i = find(self.data == 0);
            self.data(i) = NaN;
            
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        function fs = Fs(self)
            l = length(self.dnum);
            s = self.dnum(2:l) - self.dnum(1:l-1);
            fs = 1.0/(median(s)*86400);
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        function toTextFile(self, filepath)
           % toTextFile(filepath);
            %
            fout=fopen(filepath, 'w');
            for c=1:length(self.dnum)
                fprintf(fout, '%15.8f\t%s\t%5.3e\n',self.dnum(c),datestr(self.dnum(c),'yyyy-mm-dd HH:MM:SS.FFF'),self.data(c));
            end
            fclose(fout);
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
        function handlePlot = plot(sam_vector, varargin)
            % SAM/PLOT plot sam data
            % handle = plot(sam_vector, yaxisType, h, addgrid, addlegend, fillbelow);
            % to change where the legend plots set the global variable legend_ypos
            % a positive value will be within the axes, a negative value will be below
            % default is -0.2. For within the axes, log(20) is a reasonable value.
            % yaxisType is like 'logarithmic' or 'linear'
            % h is an axes handle (or an array of axes handles)
            % use h = generatePanelHandles(numgraphs)

            % Glenn Thompson 1998-2009
            %
            % % GTHO 2009/10/26 Changed marker size from 5.0 to 1.0
            % % GTHO 2009/10/26 Changed legend position to -0.2
            [yaxisType, h, addgrid, addlegend, fillbelow] = matlab_extensions.process_options(varargin, 'yaxisType', 'linear', 'h', [], 'addgrid', false, 'addlegend', false, 'fillbelow', false);
            legend_ypos = -0.2;

            % colours to plot each station
            lineColour={[0 0 0]; [0 0 1]; [1 0 0]; [0 1 0]; [.4 .4 0]; [0 .4 0 ]; [.4 0 0]; [0 0 .4]; [0.5 0.5 0.5]; [0.25 .25 .25]};

            % Plot the data graphs
            for c = 1:length(sam_vector)
                self = sam_vector(c);
                hold on; 
                t = self.dnum;
                y = self.data;

                debug.print_debug(sprintf('Data length: %d',length(y)),4);

                if strcmp(yaxisType,'logarithmic')
                    % make a logarithmic plot, with a marker size and add the station name below the x-axis like a legend
                    y = log10(y);  % use log plots

                    handlePlot = plot(t, y, '-', 'Color', lineColour{c}, 'MarkerSize', 1.0);

                    if strfind(self.measure, 'dr')
                        %ylabel(sprintf('%s (cm^2)',self(c).measure));
                        %ylabel(sprintf('D_R (cm^2)',self(c).measure));
                        Yticks = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50 ];
                        Ytickmarks = log10(Yticks);
                        for count = 1:length(Yticks)
                            Yticklabels{count}=num2str(Yticks(count),3);
                        end
                        set(gca, 'YLim', [min(Ytickmarks) max(Ytickmarks)],'YTick',Ytickmarks,'YTickLabel',Yticklabels);
                    end
                else

                    % plot on a linear axis, with station name as a y label
                    % datetick too, add measure as title, fiddle with the YTick's and add max(y) in top left corner
                    if ~fillbelow
                        handlePlot = plot(t, y, '-', 'Color', lineColour{c});
                    else
                        handlePlot = fill([min(t) t max(t)], [min([y 0]) y min([y 0])], lineColour{c});
                    end

                    if c ~= length(sam_vector)
                        set(gca,'XTickLabel','');
                    end

                    yt=get(gca,'YTick');
                    ytinterval = (yt(2)-yt(1))/2; 
                    yt = yt(1) + ytinterval: ytinterval: yt(end);
                    ytl = yt';
                    ylim = get(gca, 'YLim');
                    set(gca, 'YLim', [0 ylim(2)],'YTick',yt);
                    %ylabelstr = sprintf('%s.%s %s (%s)', self.sta, self.chan, self.measure, self.units);
                    ylabelstr = sprintf('%s', self.sta);
                    ylabel(ylabelstr)
                    datetick('x','keeplimits')
                end

                if addgrid
                    grid on;
                end
                if addlegend && length(y)>0
                    xlim = get(gca, 'XLim');
                    legend_ypos = 0.9;
                    legend_xpos = c/10;    
                end

            end
        end
        function scrollplot(s)

            % Created by Steven Lord, slord@mathworks.com
            % Uploaded to MATLAB Central
            % http://www.mathworks.com/matlabcentral
            % 7 May 2002
            %
            % Permission is granted to adapt this code for your own use.
            % However, if it is reposted this message must be intact.

            % Generate and plot data
            x=s.dnum();
            y=s.data();
            dx=1;
            %% dx is the width of the axis 'window'
            a=gca;
            p=plot(x,y);

            % Set appropriate axis limits and settings
            set(gcf,'doublebuffer','on');
            %% This avoids flickering when updating the axis
            set(a,'xlim',[min(x) min(x)+dx]);
            set(a,'ylim',[min(y) max(y)]);

            % Generate constants for use in uicontrol initialization
            pos=get(a,'position');
            Newpos=[pos(1) pos(2)-0.1 pos(3) 0.05];
            %% This will create a slider which is just underneath the axis
            %% but still leaves room for the axis labels above the slider
            xmax=max(x);
            xmin=min(x);
            xmin=0;
            %gs = get(gcbo,'value')+[min(x) min(x)+dx]
            S=sprintf('set(gca,''xlim'',get(gcbo,''value'')+[%f %f])',[xmin xmin+dx])
            %% Setting up callback string to modify XLim of axis (gca)
            %% based on the position of the slider (gcbo)
            % Creating Uicontrol
            h=uicontrol('style','slider',...
                'units','normalized','position',Newpos,...
                'callback',S,'min',xmin,'max',xmax-dx);
                %'callback',S,'min',0,'max',xmax-dx);
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        function plotyy(obj1, obj2, varargin)   
            [snum, enum, fun1, fun2] = matlab_extensions.process_options(varargin, 'snum', max([obj1.dnum(1) obj2.dnum(1)]), 'enum', min([obj1.dnum(end) obj2.dnum(end)]), 'fun1', 'plot', 'fun2', 'plot');
            [ax, h1, h2] = plotyy(obj1.dnum, obj1.data, obj2.dnum, obj2.data, fun1, fun2);
            datetick('x');
            set(ax(2), 'XTick', [], 'XTickLabel', {});
            set(ax(1), 'XLim', [snum enum]);
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        function self = reduce(self, waveType, sourcelat, sourcelon, stationlat, stationlon, varargin)
            % s.reduce('waveType', 'surface', 'waveSpeed', 2000, 'f', 2.0, );
            % s.distance and waveSpeed assumed to be in metres (m)
            % (INPUT) s.data assumed to be in nm or Pa
            % (OUTPUT) s.data in cm^2 or Pa.m
            [self.reduced.waveSpeed, f] = matlab_extensions.process_options(varargin, 'waveSpeed', 2000, 'f', 2.0);
            if self.reduced.isReduced == true
                disp('Data are already reduced');
                return;
            end

            self.reduced.distance = deg2km(distance(sourcelat, sourcelon, stationlat, stationlon)) *1000; % m

            switch self.units
                case 'nm'  % Displacement
                    % Do computation in cm
                    self.data = self.data / 1e7;
                    r = self.reduced.distance * 100; % cm
                    ws = waveSpeed * 100; % cm/2
                    self.measure = sprintf('%sR%s',self.measure(1),self.measure(2:end));
                    switch self.reduced.waveType
                        case 'body'
                            self.data = self.data * r; % cm^2
                            self.units = 'cm^2';
                        case 'surface'
                            wavelength = ws / f; % cm
                            try
                                    self.data = self.data .* sqrt(r * wavelength); % cm^2
                            catch
                                    debug.print_debug('mean wavelength instead',5)
                                    self.data = self.data * sqrt(r * mean(wavelength)); % cm^2            
                            end
                            self.units = 'cm^2';
                            self.reduced.isReduced = true;
                        otherwise
                            error(sprintf('Wave type %s not recognised'), self.reduced.waveType); 
                    end
                case 'Pa'  % Pressure
                    % Do computation in metres
                    self.data = self.data * self.reduced.distance; % Pa.m    
                    self.units = 'Pa m';
                    self.reduced.isReduced = true;
                    self.measure = sprintf('%sR%s',self.measure(1),self.measure(2:end));
                otherwise
                    error(sprintf('Units %s for measure %s not recognised', self.units, self.measure));
            end
            self.reduced.sourcelat = sourcelat;
            self.reduced.sourcelon = sourcelon;
            self.reduced.stationlat = stationlat;
            self.reduced.stationlon = stationlon;
            
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
        function [dnumarray, staarray, ltaarray, ratioarray] = detect(self, varargin)
            % detect(self, 'stalen', stalen, 'ltalen', ltalen, 'stepsize', stepsize, ...
            %     'ratio_on', ratio_on, 'ratio_off', ratio_off, 'boolplot', boolplot, 'boollist', boollist )
            [stalen, ltalen, stepsize, ratio_on, ratio_off, boolplot, boollist] = matlab_extensions.process_options(varargin, ...
                'stalen', 10, 'ltalen', 120, 'stepsize', 10, 'ratio_on', 1.5, 'ratio_off', 1.1, ...
                'boolplot', false, 'boollist', true);
          
            % Run an STA/LTA detector and plot results
            i=0;
            trigger_on=false;
            cc=0;
            % Make sta & lta equal to last good value when NaN
            sta_lastgood = eps;
            lta_lastgood = eps;
            event = 0;
            ontime=[];
            offtime=[];
            for c=ltalen: stepsize: length(self.data)
                cc=cc+1;
                if ~trigger_on % sticky lta
                    lta = nanmean(self.data(c-ltalen+1:c)) + eps; % add eps so never 0
                end
                sta = nanmean(self.data(c-stalen+1:c)) + eps; % add eps so never 0

                % Make sta & lta equal to last good value when NaN
                if isnan(sta)
                    sta = sta_lastgood;
                else
                    sta_lastgood = sta;
                end
                if isnan(lta)
                    lta = lta_lastgood;
                else
                    lta_lastgood = lta;
                end   
   
                ratio = sta./lta;
                ltaarray(cc)=lta;
                staarray(cc)=sta;
                ratioarray(cc)=ratio;
                dnumarray(cc)=self.dnum(c);
   
                if trigger_on
                    if ratio < ratio_off
                        % trigger off condition
                        offindex(event) = cc;
                        offtime(event) = dnumarray(offindex(event));
                        offY(event) = self.data(c);
                        trigger_on = false;
                        onindex = -1;
                    end
                else
                    if ratio > ratio_on
                        % trigger on condition
                        event = event + 1;
                        onindex(event) = cc;
                        ontime(event) = dnumarray(onindex(event));
                        onY(event) = self.data(c);
                        trigger_on = true;
                        offindex = -1;
                    end
                end
   
            end
            if length(offtime) < length(ontime)
                offtime(event) = self.dnum(end);
                offindex = cc;
                offY(event) = self.data(end);
            end
           
            if boolplot
                figure;
                ha(1)=subplot(1,3,1),area(dnumarray, staarray,'FaceColor','b');
                datetick('x')
                hold on;
                for j=1:length(ontime)
                    i =(dnumarray >= ontime(j) & dnumarray <= offtime(j));
                    area(dnumarray(i), staarray(i),'FaceColor', 'r')
                end
                hold off
                title('STA')

                ha(2)=subplot(1,3,2), area(dnumarray, ltaarray,'FaceColor','b');
                datetick('x')
                hold on;
                for j=1:length(ontime)
                    i =(dnumarray >= ontime(j) & dnumarray <= offtime(j));
                    area(dnumarray(i), ltaarray(i),'FaceColor', 'r')
                end
                hold off
                title('LTA')

                ha(3)=subplot(1,3,3), area(dnumarray, ratioarray,'FaceColor','b');
                datetick('x')
                hold on;
                for j=1:length(ontime)
                    i =(dnumarray >= ontime(j) & dnumarray <= offtime(j));
                    area(dnumarray(i), ratioarray(i),'FaceColor', 'r')
                end
                hold off
                title('RATIO')
                linkaxes(ha,'x');
            end
            if boollist
                for i=1:length(ontime)
                    disp(sprintf('ON %s\tOFF %s\tDURATION=%7.2f hours',datestr(ontime(i),30),datestr(offtime(i),30),24*(offtime(i)-ontime(i))));
                end
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
        function save(self, file)
            dnum = self.dnum;
            data = self.data;
            
            % substitute for station
            file = regexprep(file, 'SSSS', self.sta);
            
            % substitute for channel
            file = regexprep(file, 'CCC', self.chan);
            
            % substitute for measure
            file = regexprep(file, 'MMMM', self.measure);             
                
            % since dnum may not be ordered and contiguous, this function
            % should write data based on dnum only
            
            if length(dnum)~=length(data)
                    disp(sprintf('%s: Cannot save to %s because data and time vectors are different lengths',mfilename,filename));
                    size(dnum)
                    size(data)
                    return;
            end

            if length(data)<1
                    disp('No data. Aborting');
                return;
            end
            
            % filename

            % set start year and month, and end year and month
            [yyyy sm]=datevec(self.snum);
            [eyyy em]=datevec(self.enum);
            
            if yyyy~=eyyy
                error('can only save RSAM data to BOB file if all data within 1 year');
            end 
            
            % how many days in this year?
            daysperyear = 365;
            if (mod(yyyy,4)==0)
                    daysperyear = 366;
            end
            
            % Substitute for year        
            fname = regexprep(file, 'YYYY', sprintf('%04d',yyyy) );
            fprintf('Looking for file: %s\n',fname);

            if ~exist(fname,'file')
                    debug.print_debug(['Creating ',fname],2)
                    sam.makebobfile(fname, daysperyear);
            end            

            datapointsperday = 1440;

            % round times to minute
            dnum = round((dnum-1/86400) * 1440) / 1440;

            % find the next contiguous block of data
            diff=dnum(2:end) - dnum(1:end-1);
            i = find(diff > 1.5/1440 | diff < 0.5/1440);        

            if length(i)>0
                % slow mode

                for c=1:length(dnum)

                    % write the data
                    startsample = round((dnum(c) - datenum(yyyy,1,1)) * datapointsperday);
                    offset = startsample*4;
                    fid = fopen(fname,'r+');
                    fseek(fid,offset,'bof');
                    debug.print_debug(sprintf('saving to %s, position %d',fname,startsample),3)
                    fwrite(fid,data(c),'float32');
                    fclose(fid);
                end
            else
                % fast mode

                % write the data
                startsample = round((dnum(1) - datenum(yyyy,1,1)) * datapointsperday);
                offset = startsample*4;
                fid = fopen(fname,'r+','l'); % little-endian. Anything written on a PC is little-endian by default. Sun is big-endian.
                fseek(fid,offset,'bof');
                debug.print_debug(sprintf('saving to %s, position %d of %d',fname,startsample,(datapointsperday*daysperyear)),3)
                fwrite(fid,data,'float32');
                fclose(fid);
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        function self = resample(self, varargin)
        %RESAMPLE resamples a sam object at over every specified intercrunchfactor
        %   samobject2 = samobject.resample('method', method, 'factor', crunchfactor)
        %  or
        %   samobject2 = samobject.resample(method, 'minutes', minutes)
        %
        %   Input Arguments
        %       samobject: sam object       N-dimensional
        %
        %       METHOD: which method of sampling to perform within each sample
        %                window
        %           'max' : maximum value
        %           'min' : minimum value
        %           'mean': average value
        %           'median' : mean value
        %           'rms' : rms value (added 2011/06/01)
        %           'absmax': absolute maximum value (greatest deviation from zero)
        %           'absmin': absolute minimum value (smallest deviation from zero)
        %           'absmean' : mean deviation from zero (added 2011/06/01)
        %           'absmedian' : median deviation from zero (added 2011/06/01)
        %           'builtin': Use MATLAB's built in resample routine
        %
        %       CRUNCHFACTOR : the number of samples making up the sample window
        %       MINUTES:       downsample to this sample period
        %       (CRUNCHFACTOR will be calculated internally)
        %
        % Examples:
        %   samobject.resample('method', 'mean')
        %       Downsample the sam object with an automatically determined
        %           sampling period based on timeseries length.
        %   samobject.resample('method', 'max', 'factor', 5) grab the max value of every 5
        %       samples and return that in a waveform of adjusted frequency. The output
        %       sam object will have 1/5th of the samples, e.g. from 1
        %       minute sampling to 5 minutes.
        %   samobject.resample('method', 'max', 'minutes', 10) downsample the data at
        %       10 minute sample period       
        %
        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
            [method, crunchfactor, minutes] = matlab_extensions.process_options(varargin, 'method', self.measure, 'factor', 0, 'minutes', 0);

        
            persistent STATS_INSTALLED;

            if isempty(STATS_INSTALLED)
              STATS_INSTALLED = ~isempty(ver('stats'));
            end

            if ~(round(crunchfactor) == crunchfactor) 
                disp ('crunchfactor needs to be an integer');
                return;
            end

            for i=1:numel(self)
                samplingIntervalMinutes = 1.0 / (60 * self(i).Fs());
                if crunchfactor==0 & minutes==0 % choose automatically
                    choices = [1 2 5 10 30 60 120 240 360 ];
                    days = max(self(i).dnum) - min(self(i).dnum);
                    choice=max(find(days > choices));
                    minutes=choices(choice);
                end

                if minutes > samplingIntervalMinutes
                    crunchfactor = round(minutes / samplingIntervalMinutes);
                end

                if isempty(method)
                    method = 'mean';
                end
                
                if crunchfactor > 1
                    debug.print_debug(sprintf('Changing sampling interval to %d', minutes),3)
                
                    rowcount = ceil(length(self(i).data) / crunchfactor);
                    maxcount = rowcount * crunchfactor;
                    if length(self(i).data) < maxcount
                        self(i).dnum(end+1:maxcount) = mean(self(i).dnum((rowcount-1)*maxcount : end)); %pad it with the avg value
                        self(i).data(end+1:maxcount) = mean(self(i).data((rowcount-1)*maxcount : end)); %pad it with the avg value 
                    end
                    d = reshape(self(i).data,crunchfactor,rowcount); % produces ( crunchfactor x rowcount) matrix
                    t = reshape(self(i).dnum,crunchfactor,rowcount);
                    self(i).dnum = mean(t, 1);
                    switch upper(method)

                        case 'MAX'
                            if STATS_INSTALLED
                                        self(i).data = nanmax(d, [], 1);
                            else
                                        self(i).data = max(d, [], 1);
                            end

                        case 'MIN'
                            if STATS_INSTALLED
                                        self(i).data = nanmin(d, [], 1);
                            else
                                        self(i).data = min(d, [], 1);
                            end

                        case 'MEAN'
                            if STATS_INSTALLED
                                        self(i).data = nanmean(d, 1);
                            else
                                        self(i).data = mean(d, 1);
                            end

                        case 'MEDIAN'
                            if STATS_INSTALLED
                                        self(i).data = nanmedian(d, 1);
                            else
                                        self(i).data = median(d, 1);
                            end

                        case 'RMS'
                            if STATS_INSTALLED
                                        self(i).data = nanstd(d, [], 1);
                            else
                                        self(i).data = std(d, [], 1);
                            end

                        case 'ABSMAX'
                            if STATS_INSTALLED
                                        self(i).data = nanmax(abs(d),[],1);
                            else
                                        self(i).data = max(abs(d),[],1);
                            end


                        case 'ABSMIN'
                            if STATS_INSTALLED
                                        self(i).data = nanmin(abs(d),[],1);
                            else	
                                        self(i).data = min(abs(d),[],1);
                            end

                        case 'ABSMEAN'
                            if STATS_INSTALLED
                                        self(i).data = nanmean(abs(d), 1);
                            else
                                        self(i).data = mean(abs(d), 1);
                            end

                        case 'ABSMEDIAN'
                            if STATS_INSTALLED
                                        self(i).data = nanmedian(abs(d), 1);
                            else
                                        self(i).data = median(abs(d), 1);
                            end 

                        otherwise
                            error('sam:resample:UnknownResampleMethod',...
                              'Don''t know what you mean by resample via %s', method);

                    end
                    self(i).measure = method;
                end
            end  
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function self = save2wfmeastable(self, dbname)
            datascopegt.save2wfmeas(self.scnl, self.dnum, self.data, self.measure, self.units, dbname);
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function self = despike(self, threshold)  
            % s=s.despike(threshold)
            % threshold is relative to previous and next samples
            % find spikes lasting 1 sample only
            y= self.data;
            for i=2:length(self.data)-1
                if self.data(i)>threshold*self.data(i-1)
                    if self.data(i)>threshold*self.data(i+1)
                        %sample i is an outlier
                        y(i) = mean([self.data(i-1) self.data(i+1)]);
                        disp(sprintf('Bad sample %d, time %s, before %f, this %f, after %f. Replacing with %f',i, datestr(self.dnum(i)), self.data(i-1), self.data(i), self.data(i+1), y(i)));
                    end
                end
            end
            %self.data = y;
            
            % find spikes lasting 2 samples
            %y= self.data;
            for i=2:length(self.data)-2
                if self.data(i)>threshold*self.data(i-1) & self.data(i+1)>threshold*self.data(i-1)
                    if self.data(i)>threshold*self.data(i+2) & self.data(i+1)>threshold*self.data(i+2) 
                        %sample i is an outlier
                        y(i:i+1) = mean([self.data(i-1) self.data(i+2)]);
                        disp(sprintf('Bad sample %d, time %s, before %f, these %f %f, after %f. Replacing with %f',i, datestr(self.dnum(i)), self.data(i-1), self.data(i), self.data(i+1), self.data(i+2), y(i)));
                    end
                end
            end
            self.data = y;         
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function detect_events(self, threshold)
            other = self.despike(threshold);
            diff = self.data - other.data;
            i = find(diff>0);
            event_dnum = other.dnum(i);
            event_data = other.data(i);
            
            figure
            plot(other.dnum, other.dnum)
            hold on
            plot(other.dnum, other.dnum, 'g')
            plot(event_dnum, event_data, 'ro')
            datetick('x')
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function self = remove_calibs(self)    
             for c=1:numel(self)
            % run twice since there may be two pulses per day
                    self(c).data = remove_calibration_pulses(self(c).dnum, self(c).data);
                    self(c).data = remove_calibration_pulses(self(c).dnum, self(c).data);
             end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function self = correct(self)    
             ref = 0.707; % note that median, rms and std all give same value on x=sin(0:pi/1000:2*pi)
             for c=1:numel(self)
                if strcmp(self(c).measure, 'max')
                    self(c).data = self(c).data * ref;
                end
                if strcmp(self(c).measure, '68')
                    self(c).data = self(c).data/0.8761 * ref;
                end
                if strcmp(self(c).measure, 'mean')
                    self(c).data = self(c).data/0.6363 * ref;
                end 
             end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        function self=sam2energy(self, r)
            % should i detrend first?
            e = energy(self.data, r, get(self.scnl, 'channel'), self.Fs(), self.units);
                self = set(self, 'energy', e);
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        function w=sam2waveform(self)
            w = waveform;
            w = set(w, 'station', self.sta);
            w = set(w, 'channel', self.chan);
            w = set(w, 'units', self.units);
            w = set(w, 'data', self.data);
            w = set(w, 'start', self.snum);
            %w = set(w, 'end', self.enum);
            w = set(w, 'freq', 1/ (86400 * (self.dnum(2) - self.dnum(1))));
            w = addfield(w, 'reduced', self.reduced);
            w = addfield(w, 'measure', self.measure);
        end        
    end % end of methods
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FILE LOAD AND SAVE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%    
    methods(Access = public, Static)

       function self = loadwfmeastable(sta, chan, snum, enum, measure, dbname)
            self = sam();
            [data, dnum, datafound, units] = datascopegt.load_wfmeas(station, snum, enum, measure, dbname);
            self.dnum = dnum;
            self.data = data;
            self.measure = measure;
            self.units = units;
        end

        function makebobfile(outfile, days);
            % makebobfile(outfile, days);
            datapointsperday = 1440;
            samplesperyear = days*datapointsperday;
            a = zeros(samplesperyear,1);
            fid = fopen(outfile,'w');
            fwrite(fid,a,'float32');
            fclose(fid);
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [data]=remove_calibration_pulses(dnum, data)

            t=dnum-floor(dnum); % time of day vector
            y=[];
            for c=1:length(dnum)
                sample=round(t(c)*1440)+1;
                if length(y) < sample
                    y(sample)=0;
                end
                y(sample)=y(sample)+data(c);
            end
            t2=t(1:length(y));
            m=nanmedian(y);
            calibOn = 0;
            calibNum = 0;
            calibStart = [];
            calibEnd = [];
            for c=1:length(t2)-1
                if y(c) > 10*m && ~calibOn
                    calibOn = 1;
                    calibNum = calibNum + 1;
                    calibStart(calibNum) = c;
                end
                if y(c) <= 10*m && calibOn
                    calibOn = 0;
                    calibEnd(calibNum) = c-1;
                end
            end

            if length(calibStart) > 1
                disp(sprintf('%d calibration periods found: nothing will be done',length(calibStart)));
                %figure;
                %c=1:length(y);
                %plot(c,y,'.')
                %i=find(y>10*m);
                %hold on;
                %plot([c(1) c(end)],[10*m 10*m],':');
                %calibStart = input('Enter start sample');
                %calibEnd = input('Enter end sample');
            end
            if length(calibStart) > 0
                % mask the data according to time of day
                tstart = (calibStart - 2) / 1440
                tend = (calibEnd ) / 1440
                i=find(t >= tstart & t <=tend);
                data(i)=NaN;
            end
        end  

    end % methods

end % classdef

