function plot_iceworm_response(station,freq);
% Glenn Thompson, October 1999
% Usage: plot_iceworm_response(station,freq)
% Gets instrument response data from Iceworm (all 3 systems are checked)
% for Z-channel of station and plots it at given frequencies.
% 
% station = 3 or 4 letter station id
% freq    = vector of frequencies to plot response at

TRUE=1; FALSE=0;
pfi=dbpf('aeic_rtsys');
systems=pfkeys(pfget_arr(pfi,'processing_systems'));
system_num=1;
NOT_FOUND=TRUE;
while NOT_FOUND==TRUE & system_num <= length(systems),
	current_source=systems{system_num};
	disp(['Trying source "',current_source,'"']);
	dbname = pfresolve(pfi,['processing_systems{' current_source '}{archive_database}']);
	db = dbopen( dbname, 'r' );
	db=dblookup_table(db,'sensor');
	dbinst=dblookup_table(db,'instrument');
	db=dbjoin(db,dbinst);
	db.record=dbfind(db, ['sta == "',station,'"  &&  chan == "EHZ"']);
	if db.record ~=-102
		respfile = dbfilename(db);
		response_ptr = dbresponse(respfile);
		instr_resp=(abs(eval_response(response_ptr,freq*2*pi)))./freq; 
		figure;
		loglog(freq,instr_resp);
		title([station,' EHZ']);
		xlabel('Hz');
		ylabel('counts/m');
		NOT_FOUND=FALSE;
	else
		disp('No response file found');
		system_num=system_num+1;
	end
end
