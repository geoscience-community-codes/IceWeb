function [data,samprate,DATA_FOUND]=get_iceworm_data_for_station(station,channel,start_time,end_time);

% Glenn Thompson, October 1999
% Gets data from Iceworm system for given station & channel between start_time & end_time
% All times are in UT epoch number
%
% All 3 Iceworm systems are checked
% Dropouts & mean is automatically removed
% if no data found, DATA_FOUND will be FALSE (=0)

global db aeicpf parameterspf PFS TRUE FALSE;
TRUE=1; FALSE=0;
aeicpf=dbpf('aeic_rtsys');

warning off;

% find out names of processing systems - usually 'bak','dev' and 'op'
%systems=pfkeys(pfget_arr(aeicpf,'processing_systems'));
systems={'op';'bak';'dev'};

% loop over each system until waveform data has been found - normally
% this will succeed on first attempt, but trying three systems gives
% less likelihood of failure in case of an Iceworm problem
system_num=1; % first system
data=[];samprate=[];DATA_FOUND=FALSE; % initialise - no data yet
while DATA_FOUND==FALSE & system_num <= length(systems),
	system=systems{system_num};
	% find name of waveform archive database for this system
	dbname = pfresolve(aeicpf,['processing_systems{' system '}{archive_database}']);
	% open database in 'read-only' mode
	db = dbopen( dbname, 'r' );
	% look at the waveform table - this lists filenames of where waveform data is
	db= dblookup_table( db, 'wfdisc');
	% subset with station & channel
	db = dbsubset( db, ['sta == "',station,'"']);
	db = dbsubset( db, ['chan == "',channel,'"']);
	% sort data by time
	db = dbsort(db,'time');
	% load waveform data into trace object
	tr = trload_cssgrp(db,start_time,end_time);
	% if trace object not defined, it means no records matched the request - i.e. no data
	if exist('tr','var')  % GOT DATA!
		DATA_FOUND=TRUE;
		disp([station,' ',channel,': Data found on "',system,'"']);
		nrecs=dbquery(tr,'dbRECORD_COUNT');
		tr.record=0;	
		% load all data that matched into array 'data' - should take care of split data
		for trace_num=1:nrecs 
			tr.record=trace_num-1;
			data=[data;trextract_data(tr)];
		end
		% get sample rate
		samp_rates=dbgetv(db,'samprate'); 
		samprate=samp_rates(length(samp_rates)); % most recent value
		data=rmdrop(data); % remove drop outs
		data=detrend(data); % remove trend (& mean) - needed prior to any fft to avoid spurious results
disp(['REMOVING MEAN FOR STATION: ',station])
	else % NO DATA WERE FOUND - CHECK NEXT SYSTEM
		system_num=system_num+1;
		data=NaN; samprate=NaN;	
	end
	dbclose( db );
end


function [data] = rmdrop(data);
% remove drop outs & calibration pulses - sometimes get spikes which are 1e38!!
% values greater than 1000cts are replaced with zeros

drop = find(data>1000);		% find indices where data > 1000cts
si = size(data(drop)); 		% create matrix of the appropriate size
data(drop) = zeros(si); 	% and subsitute in the zeros
