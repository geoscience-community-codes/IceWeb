function create_UTday_spectrograms(days_ago);
% spec data is saved in day-long files for each station
% This function plots day-long spectrograms for each volcano
% listed in the IceWeb parameter file

% add Antelope extensions
%use_antelope;

% global variables
global ICEWEB parameterspf PARAMETER_FILES TRUE FALSE;

% set iceweb home
ICEWEB='/home/iceweb';

% path for parameter files
PFS=[ICEWEB,'/PARAMETER_FILES'];

% create pointer to main parameter file
parameterspf=dbpf([PFS,'/parameters']);

% add paths to code
path(path,[ICEWEB,'/ICEWEB_UTILITIES']);

% add important variables
F=0.5:0.1:15.0;  % this is frequency range of archived spec data
TRUE=1;FALSE=0; % boolean

% make sure days_ago is defined - if it was missed, user probably wants todays data
if ~exist('days_ago','var')
	days_ago=0;
end

% read set of stations for each volcano from controlfile
volcanoes=read_iceweb_volcanoes;
numvolcanoes=length(volcanoes);

% work out UT year, month & day corresponding to 'days_ago'
dnum=epoch2dnum(0)-days_ago; % dnum for current UT time
[yr,mn,dy]=yyyymmdd(dnum);

% loop for all volcanoes in the controlfile
for volcano_num=1:numvolcanoes

	% close any previous plots
	close all; 

	% define useful variables
	volcano=volcanoes{volcano_num}
	stations=read_iceweb_stations(volcano)
	numstations=length(stations);

	% fetch spec data for each station listed
	% for this volcano in the IceWeb parameter file for this UT day
	for frame_num=1:numstations
		% define useful variables
		station_num=numstations+1-frame_num;
		station=stations{station_num};

		% load spectral data for this day
		[data,DATA_FOUND]=load_spec_data(yr,mn,dy,station);

		if DATA_FOUND == TRUE
			T=data(:,1);
			A=data(:,2:147);
			% calculate position of spectrogram & trace data frames for this station
			[spectrogram_position,trace_position]=...
			calculate_frame_positions(numstations,frame_num,0.9);
			% plot data
			plot_spectrogram(A',F,T,station,frame_num,spectrogram_position,[],['']);
		end
		clear data;
	end


	if sum(DATA_FOUND) > 0  % if data was loaded for ANY station, do the following
		tstr=sprintf('%s %s',volcano,datestr(dnum,1));
		title(tstr,'Color',[0 0 0],'FontSize',[16], 'FontWeight',['bold']');
		add_colorbar;
		orient tall;
		psfile=['/tmp/',volcano,'_',yr,mn,dy,'.ps'];
		eval(['print -dpsc ',psfile]);
	else
		send_IceWeb_error(['no data to plot for ',volcano]);
	end	
end
