function spectrograms(volcano,stations,data,samp_freqs,DATA_FOUND,enum);

global parameterspf TRUE;

% set up spectrogram parameters
nfft=pfget_num(parameterspf,'nfft');
overlap=pfget_num(parameterspf,'overlap');

% close all previous plots
close all;

% find where minute marks go
[Xtickmarks,Xticklabels]=find_minute_marks(enum);

% loop over stations
numstations=length(stations);
for frame_num=1:numstations
	station_num=numstations-frame_num+1;
	% check to see if data was found
	if DATA_FOUND(station_num)==TRUE
		% set up useful variables
		station=stations{station_num};
		samp_freq=samp_freqs(station_num);
		disp(['Calculating spectrogram for ',station]);
		y=data{station_num};
		% calculate the spectrogram for this station
		[A,F,T]=specgram(y,nfft,samp_freq,overlap);
		% calculate position of spectrogram & trace data frames for this station
		[spectrogram_position,trace_position]=calculate_frame_positions(numstations,frame_num,0.75);
		% plot the spectrogram for this station
		plot_spectrogram(A,F,T,station,frame_num,spectrogram_position,Xtickmarks,Xticklabels);
		plot_trace(trace_position,y,samp_freq,Xtickmarks);
		% archive spectrogram data with a 10 minute time resolution
		archive_spectrogram_data(A,station,T,enum);
	end	
end

% add title & colorbar
add_title(volcano,enum);
add_colorbar;
orient tall;

% save to temporary storage
save_postscript_image(volcano,'spectrograms');	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%

function plot_trace(trace_position,data,samp_freq,Xtickmarks);
% set axes position
axes('position',trace_position);
% trace time vector - bins are ~0.01 s apart (not 5 s as for spectrogram time)
trace_time=(1:length(data))./samp_freq;
% plot seismogram
trace_handle=plot(trace_time,data);
% set properties
set (trace_handle,'LineWidth',[0.01],'Color',[0 0 0])
set (gca,'Xtick',Xtickmarks,'XtickLabel',[''],'Ytick',[],'YTickLabel',['']);
% blow up trace detail so it almost fills frame
max_ampl = max(abs(data));
if (max_ampl == 0) % make sure that max_ampl is not zero
	max_ampl = 100;
end
%if (max_ampl > 5000) % make sure that max_ampl is not too big
%	max_ampl = 2100;
%end
if ~isnan(max_ampl) % make sure it is not NaN else will crash
	trace_range = [0 max(trace_time) -max_ampl*1.1 max_ampl*1.1];
	axis(trace_range);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Xtickmarks,Xticklabels]=find_minute_marks(enum);
% get parameters from parameter file
global parameterspf;
num_mins=pfget_num(parameterspf,'minutes_to_get');
min_freq=pfget_num(parameterspf,'min_freq');
max_freq=pfget_num(parameterspf,'max_freq');

% calculate where minute marks should be, and labels
secs_per_day=3600*24;
mins_per_day=60*24;
[y,m,d,h,mi,s]=datevec(enum);
offset=60-s;
fiddle_factor=50; % add this to time - less chance of minute marks screwing up - must be 0 to 59 s
for mark_num=1:num_mins
	Xtickmarks(mark_num)=(mark_num-1)*60+offset;
	Xtime=enum+(mark_num-1-num_mins)/mins_per_day+(offset+fiddle_factor)/secs_per_day;
	Xticklabels{mark_num}=datestr(Xtime,15);
end

%%%%%%%%%%%%%%%%%%%%%

function add_title(volcano,enum);
title_str = [volcano,'  ',datestr(enum,0),' UT'];
title(title_str,'Color',[0 0 0],'FontSize',[16], 'FontWeight',['bold']');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function archive_spectrogram_data(A,station,T,enum);
% data resolution is 0.1 Hz, 600 s.

global ICEWEB;
SPEC_DATA=[ICEWEB,'/DATA/SPEC'];

% BUILD UP LINE OF OUTPUT DATA

% time stamp
line=sprintf('%12.4f ',enum);

% average spectral amplitudes in 0.1 Hz bins from 0.5-15.0 Hz
B=abs(A); % amplitude A is a complex number
for freq=5:150;
	specamp=nanmean(B(freq,:)); % average this 0.1 Hz band throughout time
	line=[line,sprintf('%8.1f ',specamp)];
end

% WRITE TO FILE

% if line doesn't have length 1327, must be corrupted
if length(line)==1327
	% create directory if it doesn't already exist
	[yr,mn,dy]=yyyymmdd(enum);

	% progressively make directory
	dirname=[SPEC_DATA,'/',yr];
	if ~exist(dirname,'dir')
		eval(['!mkdir ',dirname]);
	end
	dirname=[dirname,'/',mn];
	if ~exist(dirname,'dir')
		eval(['!mkdir ',dirname]);
	end
	dirname=[dirname,'/',dy];
	if ~exist(dirname,'dir')
		eval(['!mkdir ',dirname]);
	end
	
	% write data to file
	fname=[dirname,'/',station,'.log'];
	fout=fopen(fname,'a');
	if fout==-1
		send_IceWeb_error(['Could not open file ',fname,' for appending spectral data']);
	else
		fprintf(fout,'%s\n',line);
		fclose(fout);
	end
else
	send_IceWeb_error(sprintf('No spectral data written for %s - line wrong length (%d)',station,length(line)));
end
