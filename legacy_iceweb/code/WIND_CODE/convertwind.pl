#!/usr/bin/perl 
################################################################
# This program processes weather station data, and is part of
# the Iceweb system
# It is called by the program getwind.csh
#
# parse weather data for web display
# Extended to all weather stations by G.Thompson, 7 June 1998.
#
################################################################

# Setup paths & modules

use lib  "/home/iceweb/ICEWEB_UTILITIES";
use iceweb_perl_utilities qw(get_time date2dnum);

$ICEWEB=$ENV{HOME}; # iceweb home
$WIND_DATA = "$ICEWEB/DATA/WIND";
		

@weatherstations=('auwind','cbwind','dhwind','gkwind','kswind','ilwind','howind','rewind');

while(@weatherstations) {
	$weatherstation = shift(@weatherstations);
#        print $weatherstation ;
	

	open (FID, "$WIND_DATA/$weatherstation.tmp") ||
	die "Sorry could not open input file $WIND/$weatherstation.tmp\n";

	($year,$mon,$mday,$hour,$min)=get_time("ut",0);
	$dnum=date2dnum($year,$mon,$mday,$hour,$min);
        print $year, $mon, $mday, $hour, $min, $dnum;
 	printf "\n";

	$fname = "$weatherstation" . "_" . "$year" . "$mon";
	open (ARC, ">>$WIND_DATA/$fname") ||
	die "Sorry could not open output file $WIND/$fname\n";

	while(<FID>) {
		($time,$ampm,$zone,$day,$month,$date,$year,$winddir,$wind)
	= /(\w+)\W+(\w+)\W+(\w+)\W+(\w+)\W+(\w+)\W+(\w+)\W+(\w+)\W+([NSEWC]*)(\d+)\D+/;
#		print $time;
#	printf "\n";
#		print $ampm;
#	printf "\n";
#		print $zone;
#	printf "\n";
#		print $winddir;
#	printf "\n";
#		print $wind;
#	printf "\n";
		if ($winddir eq "Calm") { $wind = "  0"; }
		
		if (length($wind)==1) { $wind = "  $wind"; };
		if (length($wind)==2) { $wind = " $wind" ; };
#		printf "wind (before)= %3.0f\n", $wind;
		$wind = substr($wind,0,3);
#		printf "wind (after)= %3.0f\n", $wind;

		printf ARC "%11.3f %3.0f\n", $dnum, $wind;
		printf "%11.3f %3.0f\n", $dnum, $wind;
	}

	close(FID);
	close(ARC);
#	system("rm $WIND_DATA/$weatherstation.tmp");
};

