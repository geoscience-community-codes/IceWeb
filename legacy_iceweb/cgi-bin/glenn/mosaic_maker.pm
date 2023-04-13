package mosaic_maker;
use lib  "/usr/local/apache/cgi-bin/glenn";
use lib "$ENV{ANTELOPE}/data/perl";
use Datascope;
use local_time qw(get_local_time);
require Exporter;
@ISA=qw(Exporter);
@EXPORT=qw(make_spectrogram_mosaic read_spectrogram_names plots_per_day);
@EXPORT_OK=qw($spectrogram_num @spectrogram $num_spectrograms_per_day);
$PARAMETER_FILES="/home/glenn/NEWICEWEB/PARAMETER_FILES";

sub make_spectrogram_mosaic {
# Make a spectrogram mosaic beginning $shours ago and ending $ehours ago for $volcano
# This uses the "list_of_recent_spectrogram" for each volcano, since each
# spectrogram gif file name includes a timestamp

	($volcano,$shours,$ehours,$call_type)=@_;

	# how long is spectrogram in minutes? Read from parameter file
	$num_mins=pfget("$PARAMETER_FILES/parameters.pf","minutes_to_get");

	# work out how many spectrogram plots there are per hour
	$plots_per_hour=60/$num_mins;

	# work out how many plots archived
	$days_in_archive=pfget("$PARAMETER_FILES/parameters.pf","days_in_spectrogram_archive");
	$max_hours=$days_in_archive*24;
	if ($shours>$max_hours*$plots_per_hour) {
		report_error("Maximum number of hours is $max_hours");
	}
	else
	{

		# http path to spec directory - read from parameter file
		$SPEC_HTTP=pfget("$PARAMETER_FILES/paths.pf","SPEC_HTTP");

		# read in name of recent (e.g. last 7 days) spectrogram gif files for this volcano from "list_of_recent_spectrogram"
		($last_spectrogram_num,@spectrogram)=read_spectrogram_names($volcano);	# error code -1 indicates empty array

		unless ($last_spectrogram_num==-1) {

			if ($call_type eq "auto") {
				$html_file = "$SPEC_GIFS/$volcano/l2h.html";
			}
			else
			{
				$html_file = "$SPEC_GIFS/automosaic.html";
			};

			open(OUT,">$html_file");
			if (defined(OUT)) { # output file exists

				# Print first part of html page	
				print OUT "<html><head><title>$shours to $ehours hours ago $num_mins minute spectrograms for $volcano</title>\n";
				print OUT "</head>\n";
				print OUT "<body bgcolor=\"#FFFFFF\">\n";
				print OUT "<p align=\"center\"><font size=\"4\"><strong>$volcano Volcano IceWeb Spectrograms<br></strong></font>\n";
				($year,$mon,$mday,$hour,$min)=get_local_time();
				print OUT sprintf("<h2><center>Last updated %s:%s (Alaskan time) on %s/%s/%s</center></h2>",$hour,$min,$mday,$mon,$year);
				print OUT "<p align=\"center\"><font size=\"2\">$shours to $ehours hours ago $num_mins minute spectrograms for $volcano;
				details are available by clicking each frame.  Oldest panel is upper left, youngest is lower right.</font><p>\n";
				
				# Middle part of html page 
				for ($h=$shours;$h>$ehours;$h--) {
					print OUT "<!-- $h hours behind--><p align=\"center\"><img src=\"$SPEC_HTTP/$h" . "ha.jpg\">\n";
					for ($panel_num=($h*$plots_per_hour-1);$panel_num>=(($h-1)*$plots_per_hour);$panel_num--) {
						$spectrogram_num=$last_spectrogram_num+$panel_num+1;
						$specpath="$SPEC_HTTP/$volcano/$spectrogram[$spectrogram_num]";
						print OUT "<a href=\"$specpath.gif\"><img src=\"$specpath.2.gif\" width=\"96\" height=\"150\"></a>\n";
					};
					print OUT "</p>\n";
				};
				
				# Print out end part of html page
				$maps="/internal/volcanomaps/$volcano" . "_frame.html";
				if (-e $maps) {
					print OUT "<center><Table border=2 cellpadding=2><TR>\n";
					print OUT "<TD align=middle><A HREF=\"$maps\" > network map </A></TD>\n";
					print OUT "</TR></TABLE>\n";
				};

# fluff to add to spectrograms
$fluff = "<p align=\"center\">These spectrograms are computed by the<A HREF=\"http://giseis.alaska.edu/Input/glenn/IceWeb.html\"> IceWeb system </A>using near-real-time data from the<A HREF=\"http://giseis.alaska.edu/Input/kent/Iceworm.html\"> Iceworm system </A>at the University of Alaska<A HREF=http://www.gi.alaska.edu/> Geophysical Institute </A>.\n";

				print OUT "$fluff";
				print OUT "<p></body></html>\n";

				# close output file
				close(OUT);
			};

			if ($call_type eq "request") {
				print "<html><head><title>Click</title>\n";
				print "</head>\n";	
				print "<body><p>Spectrogram mosaic created - click <a href=\"$SPEC_HTTP/automosaic.html\">here</a><p></body></html>\n";	
			} 
		};
	};	
	return 1;
};
	
sub read_spectrogram_names {	
	# This routine looks up a file which lists filenames of last ($num_spectrogram_plots_per_day * $numdays) spectrograms
	# for a particular volcano. Each spectrogram file is timestamped.

	$volcano=$_[0];
	
	# open file which has list of last num_days of spectrogram names for this volcano
	$SPEC_GIFS=pfget("$PARAMETER_FILES/paths.pf","SPEC_GIFS");
	$infile = "$SPEC_GIFS/$volcano/list_of_recent_spectrograms.ext";
	open(IN,$infile);
	if (defined(IN)) {
		$num_spectrograms_per_day=plots_per_day();
		$spectrogram_num=$num_spectrograms_per_day*$num_days;
		while (read(IN, $spectrogram[$spectrogram_num],13)) {
			$spectrogram_num = $spectrogram_num - 1;
			read(IN, $filler,1);
		};
		close(IN);
		print " $spectrogram[$spectrogram_num]\n";
		return ($spectrogram_num,@spectrogram); # in perl, scalars must be returned before arrays
	}
	else
	{
		# for some reason input file cannot be opened - send error message
		report_error("Could not open $infile for input");
		return -1;
	}
};

sub plots_per_day {
# This program works out how many spectrogram plots there should be per day, based on
# parameter "minutes_to_get" in IceWeb parameter file - this is length of spectrogram plots

	$mins_per_day=24*60;
	$num_days=pfget("$PARAMETER_FILES/parameters.pf","days_in_spectrogram_archive"); # =7, put in parameter file
	$minutes_per_spectrogram=pfget("$PARAMETER_FILES/parameters.pf","minutes_to_get");
	$num_spectrograms_per_day=$mins_per_day/$minutes_per_spectrogram;
	return $num_spectrograms_per_day;
};
