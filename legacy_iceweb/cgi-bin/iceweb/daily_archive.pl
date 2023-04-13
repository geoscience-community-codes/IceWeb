#!/usr/bin/perl
# Glenn Thompson, 29 March 1999
#
use lib  "/usr/local/apache/cgi-bin/iceweb";
use mosaic_maker qw(make_spectrogram_mosaic);
use lib  "/home/iceweb/ICEWEB_UTILITIES";
use iceweb_perl_utilities qw(get_time date2dnum);

print "Content-type: text/html\n\n";
#
# Get the data submitted from ssamarchive.html
$form = <STDIN>;
#$form="Volcano=Shishaldin&day=27&month=10&year=1999";
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
if (length($month)==1) {
	$month="0" . "$month";
};
if (length($day)==1) {
	$day="0" . "$day";
};

# Validate date.
# Set up days per month. Zeroth element is ignored.
@dayspermonth = (0,31,29,31,30,31,30,31,31,30,31,30,31);
$date_error=0;
if (($month<1)||($month>12)) {
	$date_error=1; print "Month is invalid<p>\n";
	print "month = $month<p>\n";
} else {
	if (($day<1)||($day>$dayspermonth[$month])) {
		$date_error=1; print "Date is invalid<p>\n";
		print "day = $day<p>\n";
	};
};

# Check date range is between 23 Feb 1999 (when data archive began) and now.
($yr,$mon,$mday,$hour,$min)=get_time("ut",0);
$dateend=date2dnum($yr,$mon,$mday,$hour,$min);
$datestart=date2dnum("1999","02","23","0","0");
$date=date2dnum($year,$month,$day,"0","0");

if (($date<$datestart)||($date>$dateend)) {
	$date_error=1; print "Date must be between 23 02 1999 and present<p>\n";
	print "Date $date   datestart $datestart   dateend $dateend<p>\n";
};

if ($date_error==0) {
	# Write out html which sources correct gif image
	$gifpath="/usr/local/Mosaic/AVO/internal/ICEWEB/SPECTROGRAMS/$volcano/$year$month/$year$month$day.gif";
	$giffile="http://www.avo.alaska.edu/internal/ICEWEB/SPECTROGRAMS/$volcano/$year$month/$year$month$day.gif";
	unless (-e $gifpath) {
		$gifpath="/usr/local/Mosaic/AVO/internal/ICEWEB/SPECTROGRAMS/$volcano/$volcano" . "_$year$month$day.gif";
		$giffile="http://www.avo.alaska.edu/internal/ICEWEB/SPECTROGRAMS/$volcano/$year$month/$volcano" . "_$year$month$day.gif";
	};
	
	#$giffile="http://www.avo.alaska.edu/internal/spec/Daily/$volcano/$volcano" . "_$year$month$day.gif";
	if (-e $gifpath) {
		print "<center> <img src=\"$giffile\"  target=\"avo\"></center><p>\n";
	} else {
		print "<center>Sorry - No plot exists for $volcano on $day $month $year<p>\n";
	};
};
print "<p><hr><p><center><a href=\"http://www.avo.alaska.edu/internal/ICEWEB/SPECTROGRAMS/archive.html\" target=\"avo\"</a>Reset</center>\n";
print "\n</body></html>";




