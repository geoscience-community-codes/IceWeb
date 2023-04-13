#!/usr/bin/perl 
# Setup paths & modules

use lib  "/home/iceweb/ICEWEB_UTILITIES";
use iceweb_perl_utilities qw(get_time date2dnum);

$ICEWEB=$ENV{HOME}; # iceweb home
$WIND_DATA = "$ICEWEB/DATA/WIND";
		

	($year,$mon,$mday,$hour,$min)=get_time("ut",0);
	$dnum=date2dnum($year,$mon,$mday,$hour,$min);

print "$year $mon $mday $hour $min\n";
print "$dnum\n";
