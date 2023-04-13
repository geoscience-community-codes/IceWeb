package local_time;
use lib "$ENV{ANTELOPE}/data/perl";
use Datascope;
require Exporter;
@ISA=qw(Exporter);
@EXPORT=qw(get_local_time);
@EXPORT_OK=qw($year $mon $mday $hour $min);

sub get_local_time {
	# use Perl localtime function - would be good to replace this Perl routine with epoch2str
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);

	# month returned by local time has 0 for Jan, 1 for Feb,... make it 1 for Jan, 2 for Feb, ...
	$mon=$mon+1;

	# Hack required since perl function 'localtime' returns only 2 digit year
	# Mitch Robinson possible mods
	if ($year < 1000 ) {
      		$year = $year + 1900;
    	}
	
#	if ($year > 90) { 
#		$year = "19" . $year;
#	} else {
#		$year = "20" . $year;
#	};

	# make sure month, day, hour & minute are all 2 digit strings
	if (length($mon)==1) { $mon = "0" . "$mon"; };
	if (length($mday)==1) { $mday = "0" . "$mday"; };
	if (length($hour)==1) { $hour = "0" . "$hour"; };
	if (length($min)==1) { $min = "0" . "$min"; };

	# return results
	return ($year,$mon,$mday,$hour,$min);
};
