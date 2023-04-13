package read_database;
# environment variables are not inherited by cgi scripts,
# so unfortunately have to replace environment variables
# with hard coded paths! the downside is these need manually
# upgrading whenever Antelope is upgraded/moved

#use lib "$ENV{ANTELOPE}/data/perl";
use lib "/opt/antelope/4.2/data/perl";
use Datascope;
require Exporter;
@ISA=qw(Exporter);
@EXPORT=qw(VolcanoNames StationNames);
@EXPORT_OK=qw(@volcanoes @stations);

$database = "/iwrun/op/db/archive/archive";

sub VolcanoNames {
	@db = dbopen($database,"r");
	@db = dblookup(@db,"","network","","");
	@db = dbsubset(@db,"nettype == 'vo'");
	$nrecs = dbquery(@db,'dbRECORD_COUNT');
#	print $nrecs;
	for ( $rec_num = 0 ; $rec_num < $nrecs ; $rec_num++ ) { 
		$db[3] = $rec_num;
		$volids[$rec_num]=dbgetv(@db, qw(net)); 
		$netname=dbgetv(@db, qw(netname));
		@mix=split(/Volcano Network/,$netname);
		$volcano = $mix[0];
		$volcano =~ s/ //g;
		$volcanoes[$rec_num]=$volcano;
	};
	return @volcanoes;
};

sub StationNames {
	$volcano=$_[0];
	@db = dbopen($database,"r");
	@db = dblookup(@db,"","network","","");
	@db = dbsubset(@db,"netname == '$volcano Volcano Network'");
	@dba = dblookup(@db,"","affiliation","","");
	@db = dbjoin(@db,@dba);
	$nrecs = dbquery(@db,'dbRECORD_COUNT');
	@stations=undef;
	for ( $rec_num = 0 ; $rec_num < $nrecs ; $rec_num++ ) { 
		$db[3] = $rec_num;
		$stations[$rec_num] = dbgetv(@db, qw(sta)); 
	};
	return @stations;
};


