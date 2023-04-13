#!/usr/local/bin/perl
# Glenn Thompson, AVO, 20 May 1998
#
print "Content-type: text/html\n\n";
#
# Set up useful paths
require("/home/glenn/.perl_iceweb_paths");
#
# Get the data submitted from pseudoheli_request.html
$form = <STDIN>;
#$LEN=length($form);
#$form="Station=LVA&Hours=1";
#print "$form\n";
#
# Strip individual variables from input stream
$form=~ s/=/&/g;
$form=~ s/\+/ /g;
@mix = split(/&/,$form);
shift @mix;
$station=shift @mix;
shift @mix;
$hours=shift @mix;
shift @mix;

print "<html><body><h1>Your request</h1>\n";
print "Station: $station<p>\n";
print "Hours: $hours<p>\n";

use Datascope;
($gsec,$gmin,$ghour,$gdd,$gmm,$gyy,$gwday,$gyday,$gisdst)=gmtime(time-$hours*3600);
if (length($gdd)==1) { $gdd = "0" . $gdd; };
$gmm = $gmm +1;
if (length($gmm)==1) { $gmm = "0" . $gmm; };
#$db = "/iwrun/op/db/archive/archive_$gyy$gmm$gdd";
$db = "/iwrun/op/db/archive/archive_archive";
system("source /home/glenn/.tcshrc");
system("source /home/glenn/.iceweb_paths");
system("source /usr/tools/setup/setenv");



if ($gyy > 50) { $gyy = "19" . $gyy;} else { $gyy = "20" . $gyy };
$dbheli = "/opt/antelope/4.1/bin/dbheli";
$chan = "SHZ";
#print "$gmm/$gdd/$gyy $ghour:$gmin";
$stime = str2epoch("$gmm/$gdd/$gyy $ghour:$gmin");
if ($hours==1) {
	$twin = 300;
	$nlines = 12;
	$scale = 200;
};
if ($hours==6) {
	$twin = 1800;
	$nlines = 12;
	$scale = 400;
};
if ($hours==24) {
	$twin = 3600;
	$nlines = 24;
	$scale = 500;
};
if ($hours==48) {
	$twin = 7200;
	$nlines = 24;
	$scale = 500;
};
#print "\n$hours $twin $nlines $scale\n";
$filterstr = '"BW 0.8 5 5.0 5"';
$CGI="/usr/local/apache/cgi-bin/glenn";
chdir("$CGI");
$file_path="$CGI";
$psfile="$file_path/pseudoheli_request.ps";
$giffile="$file_path/pseudoheli_request.gif";

#print "$dbheli $db $station $chan $stime $twin $nlines $scale -f $filterstr -ps $psfile\n";
system ("$dbheli $db $station $chan $stime $twin $nlines $scale -f $filterstr -ps $psfile");
#print "/usr/local/bin/alchemy -Zm2 -Zr90 600p -go $psfile";
system("/usr/local/bin/alchemy -Zm2 -Zr90 600p -go $psfile");
system("cp $giffile /usr/local/Mosaic/AVO/internal/pseudoheli_request.gif");
print "<p>loading gif file<p>\n;
print "<center> <a href=\"http://www.avo.alaska.edu/internal/pseudohelicorder_plot.html\" target=\"avo\">";
print "\n</BODY><HTML>";


