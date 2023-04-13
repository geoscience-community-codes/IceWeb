function [volcano_trigger]=reduced_displacement(volcano,stations,data,samp_freqs,DATA_FOUND,enum);
% calculates dr & saves max dr, for all stations
%
% cannot use samp_freqs yet, because response data fixed at 0.1-51.3 Hz

global parameterspf TRUE FALSE;
surface_wave_speed=pfget_num(parameterspf,'surface_wave_speed');

% HACK:
% calculate wavelength at different frequencies - needed for drs calculation
% ideally this should come from number of samples, sample freq
% also dr should use response data calculated at those frequencies
freq = (1:513)*.1; freq = freq'; % 0.1-51.3 Hz
wavelength = surface_wave_speed ./freq; 

% get distance data
[distances DISTANCE_DATA_FOUND]=get_distance_data(volcano,stations);
if sum(DISTANCE_DATA_FOUND)>0

	% loop over stations, calculate dr, save max to file
	for station_num=1:length(stations)
	
		station=stations{station_num};
		DR_COMPUTED = FALSE;
		MAX_DRS(station_num)=NaN;MAX_F(station_num)=0.8;
	
		if DATA_FOUND(station_num) == TRUE  & DISTANCE_DATA_FOUND(station_num) == TRUE
	 
			% Load transfer function for this station
			[instr_resp,RESPONSE_FILE_FOUND]=load_instrument_response(station);
			if RESPONSE_FILE_FOUND == TRUE
	
				disp(['Calculating dr for ',station]);
	
				% isolate data for this station
				y=data{station_num};
			
				% calculate reduced displacement
				distance=distances(station_num);
				[max_dr,max_drs,rms_disp,max_f,max_fs]=...
				calculate_dr(y,instr_resp,distance,wavelength,freq);

				% Save new dr data
				save_dr(volcano,station,enum,max_f,max_dr,max_fs,max_drs,rms_disp);
				DR_COMPUTED = TRUE;
				MAX_DRS(station_num)=max_drs;MAX_F(station_num)=max_f;	
			end
		else
			MAX_DRS(station_num)=NaN;MAX_F(station_num)=0.8;
		end
	
		if DR_COMPUTED == FALSE
			send_IceWeb_error(['No dr computed for ',station]);
		end
	end
	
	% run alarm scripts
	[volcano_trigger]=test_thresholds(volcano,MAX_DRS,MAX_F,enum);
end
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [instr_resp,RESPONSE_FILE_FOUND]=load_instrument_response(station);
global ICEWEB TRUE FALSE;
RESPONSE=[ICEWEB,'/DATA/RESPONSE'];

RESPONSE_FILE_FOUND=FALSE;
instrument_response_file=[RESPONSE,'/',station,'.ext'];
if exist(instrument_response_file,'file')==2
	eval(['load ',instrument_response_file]);
	eval(['instr_resp = ',station,'* 1000;']);  % factor 1000 converts from counts/mm to counts/m
	RESPONSE_FILE_FOUND=TRUE;
else
	instr_resp=[];
	send_IceWeb_error(['No instrument response data for ',station,' in ',RESPONSE,'. Dr cannot be computed.']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [max_dr,max_drs,rms_disp,max_f,max_fs]=calculate_dr(raw_data,instr_resp,distance,wavelength,freq);
global parameterspf;
nfft=pfget_num(parameterspf,'nfft');

% calculate power spectrum		
Pxx = spectrum(raw_data,nfft); % this function behaves wierdly depending on length of raw_data to nfft - i suspect dr calculated reflects first 10s of 10m window only!

% calculate normalised amplitude spectrum
raw_spectrum = sqrt(2)*sqrt(Pxx(:,1)./length(Pxx)); 

% deconvolution of instrument response - this is displacement spectrum
displacement_spectrum=raw_spectrum./instr_resp; %m

% calculate dr. Factor 10000 converts m^2 to cm^2
dr = displacement_spectrum*10000*distance;

% find maximum dr in a 0.8-10 Hz band
[max_dr,max_index] = max(dr(8:100));

% find frequency at which this occurs
max_f = freq(max_index+7);

% eliminate calibration pulses and silly values 
ratio = nanmean(dr(212:213))/nanmean(dr(180:200));
if (ratio > 4) | (max_dr > 999.9)
 	max_dr = NaN;
 	max_f = NaN;
end

% calculate drs.
drs = displacement_spectrum*10000*sqrt(distance).*sqrt(wavelength);

% find maximum dr in a 0.8-10 Hz band
[max_drs,max_index] = max(drs(8:100));

% find frequency at which this occurs
max_fs = freq(max_index+7);

% eliminate calibration pulses and silly values 
ratio = nanmean(drs(212:213))/nanmean(drs(180:200));
if (ratio > 4) | (max_drs > 999.9)
 	max_drs = NaN;
 	max_fs = NaN;
end

% find displacement in 0.8-5 Hz band in micrometers
rms_disp = sum(displacement_spectrum(8:50))/10*1000000;
if isnan(max_drs)
	rms_disp=NaN;
else
	rms_disp = sum(displacement_spectrum(8:50))/10*1000000;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function save_dr(volcano,station,enum,max_f,max_dr,max_fs,max_drs,rms_disp);

global ICEWEB;
DR_DATA=[ICEWEB,'/DATA/DR'];

[yr,mn,dy]=yyyymmdd(enum);

% progressively make sure directory stem exists
dirname=[DR_DATA,'/',yr];
if exist(dirname,'dir')~=7
	eval(['!mkdir ',dirname]);
end
dirname=[dirname,'/',mn];
if exist(dirname,'dir')~=7
	eval(['!mkdir ',dirname]);
end
dirname=[dirname,'/',dy];
if exist(dirname,'dir')~=7
	eval(['!mkdir ',dirname]);
end
dirname=[dirname,'/',volcano];
if exist(dirname,'dir')~=7
	eval(['!mkdir ',dirname]);
end

% write data
fname=[dirname,'/',station,'.log'];
fptr = fopen(fname,'a');
if fptr==-1
	send_IceWeb_error(['Could not open file ',fname,' for appending dr data']);
else
	fprintf(fptr,'%7.3f %13.4f\n',max_drs,enum);
	fclose(fptr);
	% following data is archived for later analysis - not used in IceWeb
	fname=[dirname,'/',station,'.ext'];
	fptr = fopen(fname,'a');
	fprintf(fptr,'%13.4f %4.1f %7.3f %4.1f %7.3f %7.3f\n',...
	enum,max_f,max_dr,max_fs,max_drs,rms_disp);
	fclose(fptr);
end
