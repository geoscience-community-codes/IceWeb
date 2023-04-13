#!/usr/bin/perl -w
# Glenn Thompson, September 1999
# This is the main script controlling iceweb

$t0=time;

# Setup paths & modules
$ICEWEB=$ENV{HOME}; # iceweb home
$PFS="$ENV{PFS}"; # parameter files
$ALCHEMY="/usr/local/bin/alchemy";

use lib "$ENV{ANTELOPE}/data/perl"; # antelope-perl interface
use Datascope; # Datascope.pm module

use lib "$ENV{HOME}/ICEWEB_UTILITIES"; # utilities for talking to iceweb parameter files
use iceweb_perl_utilities qw(send_IceWeb_error read_volcanoes read_drplots get_time update_web_pages);

use lib "$ENV{CGI}"; # cgi scripts
use mosaic_maker qw(make_spectrogram_mosaic read_spectrogram_names plots_per_day);

# Setup useful paths
$SPEC_GIFS=pfget("$PFS/paths.pf","SPEC_GIFS");

# Change directory
chdir("$ICEWEB/REAL_TIME_CODE");

# fluff to add to spectrograms - set up here so it isn't repeated several times
$fluff = "<p align=\"center\">These spectrograms are computed by the<A HREF=\"http://giseis.alaska.edu/internal/ICEWEB/ONLINE_DOCUMENTATION/IceWeb.html\"> IceWeb system </A>using near-real-time data from the<A HREF=\"http://giseis.alaska.edu/Input/kent/Iceworm.html\"> Iceworm system </A>at the University of Alaska<A HREF=http://www.gi.alaska.edu/> Geophysical Institute </A>.\n";

# dynamically remake internal page menus
&update_web_pages();

# Check to see if any matlab engines are already running - if not, run spectrograms & dr plots
$RAN_FLAG = run_matlab();

if ($RAN_FLAG == 1) {

	# Read list of volcanoes
	@volcanoes=read_volcanoes();
	$NUMVOLCANOES=$#volcanoes;

	for ($volcano_num=0;$volcano_num<=$NUMVOLCANOES;$volcano_num++) {
	# for all volcanoes in IceWeb parameter file
	# convert temporary postscript images to permanent gif images
	# update last10min spectrogram html page & last 2 hour mosaic html page

		# make shortcut to this volcano
		$volcano = $volcanoes[$volcano_num];

		# see if a temporary postscript image of spectrogram exists for this volcano
		$psfile="/tmp/spectrograms" . "_" . "$volcano.ps";
		if (-e $psfile) {
			# postscript image does exist!
			print "$psfile found\n";
	
			# create a timestamp - this will be used as part of permanent spectrogram gif image filename
			($year,$mon,$mday,$hour,$min)=get_time("local",0);
			$timestamp = "$year" . "$mon" . "$mday" . "_" . "$hour" . "$min";
	
			# if permanent directory doesn't exist, make it
			$GIFPATH = "$SPEC_GIFS/$volcano";
			unless (-e $GIFPATH) {mkdir($GIFPATH,0777);};
	
			# permanent spectrogram gif image filename (without extension)
			$giffile="$GIFPATH/$timestamp";
	
			# use alchemy to convert ps to gif
			system("$ALCHEMY $psfile -Zm2 -Zc1 -Zo 600p -Z+ $giffile.gif -go -Q"); # make large image for individual viewing
			system("$ALCHEMY $psfile -Zm2 -Zc1 -Zb 1i 1.6i 0.8i 0.9i -Zo 200p -Z+ $giffile.2.gif -go -Q"); # make small image for mosaics - clip off sides too
			system("rm $psfile"); # remove the postscript file
	
			# create last 10 minute html for each volcano
			make_last10min_spectrogram_html($volcano,$timestamp);
	
			# add newest plot to list of archived spectrograms
			update_spectrogram_archive($volcano,$timestamp);
	
			# make last 2 hour mosaic
			$call_type="auto";
			make_spectrogram_mosaic($volcano,2,0,$call_type);
		} 
		else
		{
			# no postscript image found - possible error
			print "$psfile not found\n";	
		};
	
		# Convert the reduced displacement file if postscript image exists
		convert_drplot_ps2gif($volcano);
	};
		
	# touch following file to say when iceweb last ran successfully - this is checked by checker.pl
	system("touch $ICEWEB/TESTING/last_ran");

};

# Record run time
$t1=time;
$dt=$t1-$t0;
open(TIME,">>$ICEWEB/TESTING/run_time");
if (defined(TIME)) {
	print TIME "$dt ";
	close(TIME);
}



	
########### SUBROUTINES ################

sub run_matlab {
# This routine runs the Matlab IceWeb code, which is the bulk of the IceWeb real-time system.
# However, the Matlab routines are only run if there are no Matlab engines already running on
# the IceWeb computer. If multiple IceWeb engines were allowed, the computer could quickly
# grind to a halt, and also impact on Iceworm.

	# set paths
	$grepresults = "/tmp/grepresults";

	# use grep to see if other Matlab engines are already running on IceWeb computer
	system("ps -e -o pid -o comm | grep start_matlab_engine > $grepresults");
	unless (-z $grepresults) {
		# Matlab engines already running - don't start Matlab IceWeb code!
		send_IceWeb_error("IceWeb not started because a Matlab engine is already running");
		$RAN_FLAG = 0;
	} 
	else 
	{
		# Okay to run Matlab IceWeb code
		print "Matlab IceWeb code started\n";
		system("$ICEWEB/ICEWEB_UTILITIES/start_matlab_engine iceweb $ICEWEB/REAL_TIME_CODE");
		print "Matlab IceWeb code finished\n";
		$RAN_FLAG = 1;
	};
	unlink($grepresults);
	return $RAN_FLAG;
};

 

sub make_last10min_spectrogram_html {
# Web page for the last 10 minute spectrogram needs rewriting, since the gif file name changes (it includes a time stamp)
# Usually it is only the last line that changes here. Alternatively could cut off last line, and paste onto old html file.
	($volcano,$timestamp)=@_;
	
	$html_file="$SPEC_GIFS/$volcano/l10m.html";
	open(OUT,">$html_file");
	if (defined(OUT)) {
		# write html file
		print OUT "<html><head><title>$volcano Volcano IceWeb Spectrograms</title>\n";
		print OUT "<META HTTP-EQUIV=\"Refresh\" CONTENT=600; URL=\"l10m.html\"></head>\n";
		print OUT "<H1><center>$volcano Volcano IceWeb Spectrograms</center></H1>\n";
		print OUT "$fluff";
		print OUT "<p><center><img src=\"$timestamp.gif\"></center></HTML>\n";
		close(OUT);
	}
	else
	{
		# for some reason html file cannot be opened for output - send error message
		send_IceWeb_error("Could not open $html_file for output");
	}
	return 1;
};

sub update_spectrogram_archive {
# Update the list of recent spectrogram gif-file file-names
# This is needed so that mosaics can be made
# Updating consists of appending last gif file name to bottom,
# plus removing oldest gif files name from top

	($volcano,$timestamp)=@_;
	
	$fname="$SPEC_GIFS/$volcano/list_of_recent_spectrograms";
	open(OUT,">>$fname.ext");
	if (defined(OUT)) {
		# append current gif file name to list
		print OUT "$timestamp\n";
		close(OUT);

		# don't want the file to grow infinitely large - so cut off top of file
		$num_days=pfget("$PFS/parameters.pf","days_in_spectrogram_archive");
		$num_spectrograms_per_day=plots_per_day();
		$taillength=$num_spectrograms_per_day*$num_days;
		system("tail -$taillength $fname.ext > $fname.tmp");
		system("mv $fname.tmp $fname.ext");
	}
	else
	{
		# for some reason output file cannot be opened - send error message
		send_IceWeb_error("Could not open $fname.ext for output");
	}
	return 1;
};

sub convert_drplot_ps2gif {
# Convert postscript dr plots to gif files, then remove postscript files

	$volcano=$_[0];
	
	# find out home for dr gif plots
	$DR_GIFS=pfget("$PFS/paths.pf","DR_GIFS");

	# read in list of dr plots that should have been produced for this volcano
	@drplots=read_drplots($volcano);

	
	if (@drplots eq "") { # no plots were requested - nothing to do!
		print "No drplots are requested for $volcano\n";
	}
	else
	{ # plots were requested - go through list and convert each one
		foreach $drplot (@drplots) { 
			$psfile = "/tmp/dr" . "$drplot" . "_$volcano" . ".ps";
			$giffile = "$DR_GIFS/dr" . "$drplot" . "_$volcano" . ".gif";
			if (-e "$psfile") { # dr plot exists - convert it using alchemy
				print "$psfile -> $giffile\n";
				system("$ALCHEMY $psfile -Zm2 -Zc1 -Zo 600p -Z+ $giffile -go -Q");	
				system("rm $psfile");
			}
			else
			{
				# for some reason dr plot postscript doesn't exist
				print "$psfile does not exist\n";
			};
		};
	};
	return 1;
};

