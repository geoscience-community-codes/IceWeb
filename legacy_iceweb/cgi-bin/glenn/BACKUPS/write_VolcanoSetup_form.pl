#!/usr/bin/perl -w
use lib "$ENV{ANTELOPE}/data/perl";
use Datascope;
use lib "/home/glenn/NEWICEWEB";
use read_parameters qw(read_volcanoes read_stations read_windstation read_drplots read_thresholds read_useinav read_allowed_drplots);

write_VolcanoSetup_form($ARGV[0]);

############################################################################################

sub write_VolcanoSetup_form {

	# read volcano name passed as argument
	$volcano=$_[0];

	# see if a setup file for this volcano already exists
	$fname="/home/glenn/NEWICEWEB/PARAMETER_FILES/$volcano.pf";
	if (-e $fname) { # get current/last volcano setup
		@stations=&read_stations($volcano);
		@thresholds=&read_thresholds($volcano,@stations);
		@useinav=&read_useinav($volcano,@stations);
		@drplots=sort(&read_drplots($volcano));
		$windstation=&read_windstation($volcano);
		# check to see if it is currently on IceWeb
		$on_iceweb=volcano_is_currently_on_IceWeb($volcano);
		if ($on_iceweb == 0) { # this is an old setup
			$message="This volcano used to be on IceWeb: using most recent setup";
		}
		else
		{
			$message="This volcano is currently on IceWeb: Using current setup";
		}
	}
	else
	{ # make a blank setup
		@stations=("","","","","","");
		@thresholds=(0,0,0,0,0,0);
		@useinav=(0,0,0,0,0,0);
		@drplots=();
		$windstation="nowind";
		$message="This volcano has never been on IceWeb: using a blank setup"
	};					

	# Print out top of html page
	print "<HTML><HEAD>\n";
	print "<TITLE> IceWeb Setup for $volcano Volcano </TITLE></HEAD>\n";
	print "<BODY><FORM ACTION=\"http://www.avo.alaska.edu/cgi-bin/glenn/volcano_setup.pl\" METHOD=\"POST\">\n";
	print "<hr>\n";
	print "<FONT SIZE=7> <center> IceWeb Setup for $volcano Volcano </center></FONT><P>\n";
	print "<FONT SIZE=5> <center> $message </center></FONT><P>\n";

	# horizontal line separator
	print "<hr>\n";

	##### STATION & ALARM SETUP #####

	# display info about the station/alarm setup
	print "<h1>Stations / Alarms</H1><p>\n";
	print "Select up to 6 stations that you want to appear on spectrograms and reduced displacement plots.<br>
	Then for each station, select a threshold level. An alarm will be sent whenever more than 1 station is 
	above its threshold level.<p>
	Alarms will also be sent if the average reduced displacement at <em>selected</em> stations exceeds the average 
	threshold of those stations.<br> If you wish a station to
	contribute to this average, please check the 'average' box for that station.<p>
	To remove a station from the alarm (e.g. because it is noisy) enter a large value
	for threshold (e.g. 9999) and remove it from the average.<p>\n";

	# add space for up to 6 volcanoes
	unless ($#stations>=5) {
		for ($extra_station_num=$#stations+1;$extra_station_num<=5;$extra_station_num++) {
			$stations[$extra_station_num]="";
			$thresholds[$extra_station_num]=0;
			$useinav[$extra_station_num]=0;
		}
	};
	
	# display current station / alarm setup info for this volcano in a table
	print "<TABLE>\n";
	print "<TR><TD><BR></TD><TH>Stations</TH><TH>Threshold<BR>(cm^2)</TH><TH>Average?</TH></TR>\n";		
	for ($station_num=0;$station_num<=$#stations;$station_num++) {
		$station_plus=$station_num+1;
		print "<TR><TH>$station_plus</TH>\n";
		print "<TD><INPUT TYPE=\"text\" NAME=\"station\" SIZE=\"4\" VALUE=\"$stations[$station_num]\"></TD>\n";
		$threshold=$thresholds[$station_num];
		if ($threshold == 0) {
			print "<TD><INPUT TYPE=\"text\" NAME=\"threshold\" SIZE=\"4\" VALUE=\" \"></TD>\n";
		}
		else
		{
			print "<TD><INPUT TYPE=\"text\" NAME=\"threshold\" SIZE=\"4\" VALUE=\"$thresholds[$station_num]\"></TD>\n";
		}
		if ($useinav[$station_num] == 1) {
			print "<TD><INPUT TYPE=\"checkbox\" NAME=\"av\" VALUE=\"1\" CHECKED>";}
		else {
			print "<TD><INPUT TYPE=\"checkbox\" NAME=\"av\" VALUE=\"1\">";
		};
		print "</TD></TR>\n";
	};
	print "</TABLE>\n";

	# horizontal line separator
	print "<hr>\n";

	##### REDUCED DISPLACEMENT PLOTS SETUP
	print "<H1>Reduced Displacement Plots</H1><p>\n";
	@allowed_dr_plots=&read_allowed_drplots();
	print "Which of these dr plots do you wish to be produced for $volcano ?<p>\n";
	for ($plotnum=0;$plotnum<=$#allowed_dr_plots;$plotnum++) {
		print "<INPUT TYPE=\"checkbox\" NAME=\"drplots\" VALUE=\"$allowed_dr_plots[$plotnum]\"> Last $allowed_dr_plots[$plotnum] days\n";
	};
	
	# horizontal line separator
	print "<p><hr>\n";

	##### WIND STATION SETUP #####
	print "<H1>Wind station</H1><p>\n";
	print "Select wind data from one weatherstation. <br>These data will be shown on reduced displacement plots.<p>\n";
	@windstations=qw(nowind cbwind dhwind howind ilwind kswind);
	@real_names=qw(None Cold_Bay Dutch_Harbour Homer Iliamna King_Salmon);
	for ($windstation_num=0; $windstation_num <= $#windstations; $windstation_num++) {
		if ($windstation eq $windstations[$windstation_num]) {
			print "<INPUT TYPE=\"radio\" NAME=\"windstation\" VALUE=\"$windstations[$windstation_num]\" CHECKED> $real_names[$windstation_num]\n";
		}
		else
		{
			print "<INPUT TYPE=\"radio\" NAME=\"windstation\" VALUE=\"$windstations[$windstation_num]\"> $real_names[$windstation_num]\n";
		};
	};

	# horizontal line separator
	print "<hr>\n";

	# Submit & Reset Buttons
	print "<INPUT TYPE=\"submit\" VALUE=\"Submit\"><INPUT TYPE=\"reset\" VALUE=\"Reset\"></FORM>\n";

	# horizontal line separator
	print "<hr>\n";

	# Author information
	print "<ADDRESS>Prototype by Glenn Thompson, 21st September 1999</ADDRESS>\n";

	# End of html
	print "</body></html>\n";

}

sub volcano_is_currently_on_IceWeb {
# This routine checks whether the volcano name
# given is currently on IceWeb

	# read in name of volcano to be found
	$volcano = $_[0];

	# read in names of all volcanoes currently on IceWeb
	@volcanoes = &read_volcanoes();

	# set boolean values for clarity
	$FALSE=0; $TRUE=1;

	# volcano not found yet, so found is false
	$found=$FALSE;

	# loop over all volcanoes on IceWeb, until match is found, or run out of volcanoes
	$volcano_num=0;
	while ($found==$FALSE && $volcano_num<=$#volcanoes) {
		if ($volcano eq $volcanoes[$volcano_num]) {
			$found=$TRUE;
		};
		$volcano_num++;
	};

	# return result true of false
	return $found;
};
			







