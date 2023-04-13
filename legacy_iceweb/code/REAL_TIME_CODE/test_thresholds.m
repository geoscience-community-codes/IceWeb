function [volcano_trigger]=test_thresholds(volcano,max_drs,max_f,enum);

% max_drs vector can contain NaN values
% therefore so can ratios

% global variables
global pathspf parameterspf ICEWEB PFS TRUE FALSE;

% set iceweb home
ICEWEB='/home/iceweb';

% path for parameter files
PFS=[ICEWEB,'/PARAMETER_FILES'];

% create pointer to main parameter file
parameterspf=dbpf([PFS,'/parameters']);

disp('Testing dr vs. threshold values');

% setup useful variables
global TRUE FALSE ICEWEB;
stations=read_iceweb_stations(volcano);
numstations=length(stations);
volcano_trigger=FALSE;

% load thresholds (alarm data for stations)
[thresholds,use]=read_thresholds(volcano);

% calculate ratios of max_drs to thresholds
ratios=max_drs./thresholds;

% test station triggers - how many used stations above threshold?
for station_num=1:numstations
	station_trigger(station_num)=test_station_trigger(ratios(station_num),use(station_num),max_f(station_num));
end

% test volcano trigger - if >1 station above threshold, sety volcano trigger
if sum(station_trigger)>1
	volcano_trigger=TRUE;
	compose_message(volcano,stations,station_trigger,max_drs,thresholds,enum);
end
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function trig=test_station_trigger(R,use,max_f)
global TRUE FALSE;
if str2num(use)==TRUE & R>1 & max_f > 0.8
	trig=TRUE;
else
	trig=FALSE;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function compose_message(volcano,stations,triggers,max_drs,thresholds,enum);

global TRUE parameterspf;

% to send alarms to beeper, add 'beeper' to 'alarm_list' in parameters.pf
alarm_list=pfget_tbl(parameterspf,'alarm_list');

if length(alarm_list) > 0
	al_str=alarm_list{1};
	for al_no=2:length(alarm_list)
		al_str=[al_str,' ',alarm_list{al_no}];
	end

	% make a string of triggered stations
	triggered_stations=[];
	for station_num=1:length(stations)
		if triggers(station_num) == TRUE
			triggered_stations=[triggered_stations,' ',stations{station_num}];
		end
	end

	% make output message
	fam=fopen('/tmp/alarm_msg','w');
	fprintf(fam,'ICEWEB ALARM @ %s\n',volcano);
	fprintf(fam,'Dr > threshold at %s at %s\n\n',triggered_stations,datestr(enum,0));
	fprintf(fam,'STA    thrshld   dr\n');
	for station_num=1:length(stations)
		fprintf(fam,'%s: %7.2f %7.2f\n', ...
		stations{station_num},thresholds(station_num),max_drs(station_num));
	end
	fclose(fam);
end
