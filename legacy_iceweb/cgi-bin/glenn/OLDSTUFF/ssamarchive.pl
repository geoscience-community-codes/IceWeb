#!/usr/local/bin/perl
# Glenn Thompson, 29 March 1999
#
print "Content-type: text/html\n\n";
#
# Set up useful paths
require("/home/glenn/ICEWEB/OPERATIONAL/perl_iceweb_paths");
#
# Get the data submitted from ssamarchive.html
$form = <STDIN>;
#$form="Volcano=Shishaldin&day=23&month=02&year=1999";
#
# Strip individual variables from input stream
$form=~ s/=/&/g;
$form=~ s/\+/ /g;
@mix = split(/&/,$form);
shift @mix;
$volcano=shift @mix;
shift @mix;
$day=shift @mix;
shift @mix;
$month=shift @mix;
shift @mix;
$year=shift @mix;
shift @mix;

# Validate date.
# Set up days per month. Zeroth element is ignored.
@dayspermonth = (0,31,29,31,30,31,30,31,31,30,31,30,31);
$date_error=0;
if (($month<1)||($month>12)) {
	$date_error=1; print "Month is invalid\n";
} else {
	if (($day<1)||($day>$dayspermonth[$month])) {
		$date_error=1; print "Date is invalid\n";
	};
};

# Check date range is between 23 Feb 1999 (when data archive began) and now.
($sec,$min,$hour,$mday,$mon,$yr,$wday,$yday,$isdst)=localtime(time);
if ($yr>90) {
	$yr=$yr+1900;
} else {
	$yr=$yr+2000;
};
$datenow=$yr*600+$mon*40+$mday;
$datestart=1999*600+2*40+23;
$date=$year*600+$month*40+$day;
if (($date<$datestart)||($date>$datenow)) {
	$date_error=1; print "date must be between 23 02 1999 and present\n";
};

if ($date_error==0) {
	# Write out html which sources correct gif image
#	$giffile="file:/usr/local/Mosaic/AVO/internal/SSAM/$volcano/$volcano" . "_$year$month$day.gif";
	$giffile="http://www.avo.alaska.edu/internal/SSAM/$volcano/$volcano" . "_$year$month$day.gif";
	#if (-e $giffile) {
		print "<center> <img src=\"$giffile\"  target=\"avo\"></center><p>\n";
	#} else {
	#	print "<center>no data exists for $volcano on $day $month $year\n";
	#};
};
print "<p><hr><p><center><a href=\"http://www.avo.alaska.edu/internal/SSAM/ssam.html\" target=\"avo\"</a>Back</center>\n";
print "\n</body></html>";




