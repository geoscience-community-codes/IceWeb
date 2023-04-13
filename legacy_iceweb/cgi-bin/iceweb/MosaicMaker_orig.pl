#!/usr/bin/perl -w
# This script takes output from 'Make Mosaic' form
# and creates spectrogram mosaic for selected volcano
# between times given

# Setup stuff
# Setup paths & modules
# hard wired path since cgi scripts cannot import environment variables
# enviroment variables not inherited by cgi-scripts,
# so paths must be hard coded (which makes them more
# likely to break!)
#use lib "/opt/antelope/4.2u/data/perl";
use lib "/opt/antelope/4.8/data/perl";
use Datascope;
use lib  "/usr/local/apache/cgi-bin/iceweb";
use mosaic_maker_orig qw(make_spectrogram_mosaic);

# Get the data submitted from ssamarchive.html
$form = <STDIN>;
#$form="Volcano=Shishaldin&StartHours=2&EndHours=0";

# Strip individual variables from input stream
$form=~ s/=/&/g;
$form=~ s/\+/ /g;
@mix = split(/&/,$form);
shift @mix;
$volcano=shift @mix;
shift @mix;
$shours=shift @mix;
shift @mix;
$ehours=shift @mix;

# check for silliness
if ($shours<=$ehours) {
	print "<p>\nFirst number must be bigger than second number\n";
} else {
	$call_type="request";
	make_spectrogram_mosaic($volcano,$shours,$ehours,$call_type);
};
