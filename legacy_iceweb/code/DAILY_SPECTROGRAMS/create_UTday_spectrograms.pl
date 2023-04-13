#!/usr/bin/perl
# Glenn Thompson, September 1999
# This script produces 24 hour spectrograms

# Setup paths & modules
$ICEWEB=$ENV{HOME}; # iceweb home
$PFS="$ENV{PFS}"; # parameter files

use lib "$ENV{ANTELOPE}/data/perl"; # antelope-perl interface
use Datascope; # Datascope.pm module

use lib "$ENV{HOME}/ICEWEB_UTILITIES"; # utilities for talking to iceweb parameter files
use iceweb_perl_utilities qw(send_IceWeb_error read_volcanoes get_time);
$SPEC_GIFS=pfget("$PFS/paths.pf","SPEC_GIFS");

# Get days_ago
$days_ago=$ARGV[0];

# Run Matlab code - this puts postscript images into /tmp directory
$|=1;
system("$ICEWEB/ICEWEB_UTILITIES/start_matlab_engine create_UTday_spectrograms $ICEWEB/DAILY_SPECTROGRAMS $days_ago");

# Read list of volcanoes
@volcanoes=read_volcanoes();
$NUMVOLCANOES=$#volcanoes;
print "@volcanoes\n";

# LOOP OVER ALL VOLCANOES IN ICEWEB PARAMETER FILE
for ($volcano_num=0;$volcano_num<=$NUMVOLCANOES;$volcano_num++) {
	$volcano = $volcanoes[$volcano_num];

	# if a 24 hr spectrogram has been made for this volcano
	($year,$mon,$mday,$hour,$min)=get_time("ut",$days_ago);
	$datestr="$year" . "$mon" . "$mday";
print "$datestr\n";
	$tempfile="/tmp/$volcano" . "_$datestr" . ".ps";
	if (-e $tempfile) {
		
		print sprintf("\n Converting 24 hr spectrogram for %s\n",$volcano);

		# convert temporary ps to permanent gif file
		$relname = "$year" . "$mon" . "$mday" . "_" . "$hour" . "$min";
		$TEMPPATH="$SPEC_GIFS/$volcano";
		$PERMPATH="$TEMPPATH/$year" . "$mon";
		unless (-e $PERMPATH) {system("mkdir $PERMPATH")};
		$permname="$PERMPATH/$volcano_$datestr";
		system("alchemy $tempfile -Zm2 -Zc1 -Zo 600p -Z+ $permname.gif -go -Q");
		system("rm $tempfile");

		# make copy if today or yesterday (program will run for ANY day though!)
		if ($days_ago==0) {system("cp $permname.gif $TEMPPATH/currentday.gif")}
		elsif ($days_ago==1) {system("cp $permname.gif $TEMPPATH/lastday.gif")};
		} 
	else
	{
		print sprintf("\n No 24 hr spectrogram for %s\n",$volcano);
	};

};
 

