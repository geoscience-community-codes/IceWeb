#!/usr/local/bin/perl
# Glenn Thompson, 18 May 1999

$NUMDAYS=7;
###
print "Content-type: text/html\n\n";

# Set up useful paths
require("/home/glenn/ICEWEB/SYSTEM_1/perl_iceweb_paths");

# Get the data submitted from ssamarchive.html
$form = <STDIN>;
#$form="Volcano=Shishaldin&StartHours=2&EndHours=0";

# Strip individual variables from input stream
$form=~ s/=/&/g;
$form=~ s/\+/ /g;
@mix = split(/&/,$form);
shift @mix;
$vol=shift @mix;
shift @mix;
$shours=shift @mix;
shift @mix;
$ehours=shift @mix;

# check for silliness
if ($shours<=$ehours) {
	print "<p>\nFirst number must be bigger than second number\n";
} else {
	# Web path for spectrogram directory
	$specdir="http://www.avo.alaska.edu/internal/spec/";

	# open file which has list of last 144 spectrogram names for this volcano
	open(IN,"<$SPEC/$vol/lastdaynames.ext");
	$count=144*$NUMDAYS;
	while (read(IN, $spectrogram[$count],13)) {
		#print "$count \n";
		$count = $count - 1;
		read(IN, $filler,1);
	};

	# Print first part of html page
	print "<html><head><title>$shours to $ehours hours ago 10-min spectrograms for $vol</title>\n";
	print "</head>\n";
	print "<body bgcolor=\"#FFFFFF\">\n";
	print "<p align=\"center\"><font size=\"4\"><strong>$vol Volcano IceWeb Spectrograms<br></strong></font>\n";
	print "<p align=\"center\"><font size=\"2\">$shours to $ehours hours ago 10-min spectrograms for $vol;
	details are available by clicking each frame.  Oldest panel is upper left, youngest is lower right.</font><p>\n";

	# Middle part of html page 
	for ($h=$shours;$h>$ehours;$h--) {
		print "<!-- $h hours behind--><p align=\"center\"><img src=\"$specdir$h" . "ha.jpg\">\n";
		for ($e=($h*6-1);$e>=($h*6-6);$e--) {
			$counter=$count+$e+1;
			$specpath="http://www.avo.alaska.edu/internal/spec/$vol/$spectrogram[$counter]";
			#print "$counter\n";
			print "<a href=\"$specpath.gif\"><img src=\"$specpath.2.gif\" width=\"96\" height=\"150\"></a>\n";
		};
		print "</p>\n";
	};

	# Print out end part of html page
	print "<center><TD><Table border=2 cellpadding=2><TR><TD align=middle>\n";
	print "<A HREF=\"/internal/spec/DailyArchive/$vol.html\" > archived spectrograms </A></TD><TD>\n";
	$maps="/internal/volcanomaps/$vol" . "_frame.html";
	print "<A HREF=\"$maps\" > network map </A></TD></TR></TABLE>\n";
	print "<p align=\"center\">These spectrograms are computed by the  <A HREF=\"http://giseis.alaska.edu/Input/glenn/IceWeb.html\">IceWeb system</A> using near-real-time data from the <A HREF=\"http://giseis.alaska.edu/Input/kent/Iceworm.html\">Iceworm system</A> at the University of Alaska <A HREF=http://www.gi.alaska.edu/>Geophysical Institute</A><p>.\n";
	print "</body></html>\n";
};
