function [data_array,stations,channels,dnum_end_time]=getdbdataforvolcano(volcano,num_mins);
% modified from plotnet.m program of Kent Lindquist
% by Glenn Thompson, 25/03/1999
% checking for all sources ('op','bak','dev') added by Glenn May 2, 1999.
% Problem: tr from 'try_source' is not being deleted - stays in /tmp

% Get data from last num_mins minutes
% 'now' is UTC, whereas Matlab now is LOCAL
%end_time = str2epoch('now') - 60;
end_time = mep2dep(now + (9 / 24)) - 60;
start_time = end_time - num_mins * 60;

% HACK: try all different data sources
tr=try_source('op',volcano,start_time,end_time);
if ~exist('tr')
	tr=try_source('bak',volcano,start_time,end_time);
	if ~exist('tr')
		tr=try_source('dev',volcano,start_time,end_time);
	end
end
if ~exist('tr')
	eval(['!echo No Iceworm data found for IceWeb for ',volcano,' | mailx -s "IceWeb data problem" glenn']);
else
	nrecs = dbquery( tr, 'dbRECORD_COUNT');
	trace=0;
	for i=1:nrecs
		tr.record=i-1;
		data=trextract_data(tr);
		station=dbgetv(tr,'sta');
		channel=dbgetv(tr,'chan');
		if channel(3) == 'Z'
			trace=trace+1;
			stations{trace,1}=station;
			channels{trace,1}=channel;
			l=length(data);
			data_array(1:l,trace)=data;
		end
	end
	trdestroy( tr );
	dnum_end_time = epoch2dnum(end_time);
end

data=rmdrop(data); % remove drop outs
data=detrend(data); % remove trend (& mean) - needed prior to any fft to avoid spurious results


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data] = rmdrop(data);
% remove drop outs & calibration pulses - sometimes get spikes which are 1e38!!
% values greater than 1000cts are replaced with zeros

drop = find(data>1000);		% find indices where data > 1000cts
si = size(data(drop)); 		% create matrix of the appropriate size
data(drop) = zeros(si); 	% and subsitute in the zeros


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tr=try_source(current_source,volcano,start_time,end_time);
pf=dbpf('aeic_rtsys');
primary_archive = pfget(pf,'primary_system');
%dbname = pfresolve(pf,['processing_systems{' current_source '}{archive_database}']);
dbname = pfresolve(pf,['processing_systems{' primary_archive '}{archive_database}']);
%dbname=['/iwrun/',current_source,'/db/archive/archive'];
db = dbopen( dbname, 'r' );
db = dblookup_table( db, 'network' );
db = dbsubset(db, ['netname =~ /',volcano,'.*/']);
dba= dblookup_table( db, 'affiliation');
db = dbjoin( db, dba);
dbw= dblookup_table( db, 'wfdisc');
db = dbjoin(db, dbw);
% next command generates a segmentation fault with Westdahl
% but nothing unusual about db
epoch2str(start_time,'%D:%H:%M');
epoch2str(end_time,'%D:%H:%M');
db = dbsort(db,'sta','chan','time');
tr = trload_cssgrp( db, start_time, end_time );
dbclose( db );
