#! /usr/bin/perl
# Glenn Thompson, 4 Jan 2000
# a short cut to run dbheli
# Usage: heliplot d station channel
# eg. 
#        heliplot 0 PV6 SHZ
# is a plot for today (since UT midnight) for PV6 & SSLN
# eg. 
#        heliplot 1 LVA
# is a plot for UT yesterday for LVA

################## INITIALIZATION #########################
# Use Antelope Perl library
use lib "$ENV{ANTELOPE}/data/perl";

# Use Datascope.pm (this is a Perl library)
use Datascope;

# Set path for dbheli program
$dbheli = "$ENV{ANTELOPE}/bin/dbheli";

# Read days ago from command line, 0=today, 1=yesterday
($sta,$chan,$stime,$nsec)=@ARGV;

# Get database path, and gmt year, month & day corresponding to days_ago
($db,$gyy,$gmm,$gdd)=&get_gmt_time($stime);

######## dbheli arguments #################
#$chan = "SHZ"; # use only vertical component
$twin = 3600; # plot 3600s to a line
$nlines = 24; # plot 24 lines (i.e. 24 hours)
$scale = 500; # 500 counts per inch
$filterstr = '"BW 0.8 5 5.0 5"'; # use a Butterworth filter between 0.8 & 5 Hz to enhance tremor, 5 poles

################################ MAIN PROGRAM ################################################
#$PSPATH=$ENV{"PSEUDOHELI"}; # where to save pseudohelicorder plots (postscript files)
$PSPATH="/home/jjalaska"; # where to save pseudohelicorder plots (postscript files)

$psfile = "$PSPATH/$sta$gmm${gdd}.ps";
$filename = strydtime($stime);
$psfile = "$sta$gmm${gdd}.ps";
print "Creating $psfile\n";
system ("$dbheli $db $sta $chan $stime $twin $nlines $scale -f $filterstr -ps $psfile\n");

################################ SUBROUTINES #####################################

sub get_gmt_time {
$stime = $_[0]; # read input argument

# Perl routine gmtime returns "100" for Year 2000 & "0" for January - this routine fixes that
# returning "2000" and "1" respectively. It also returns correct Iceworm database path
($gsec,$gmin,$ghour,$gdd,$gmm,$gyy,$gwday,$gyday,$gisdst)=gmtime($stime);
print "$gyy $gmm $gdd $ghour $gmin $gsec\n";
if (length($gdd)==1) { $gdd = "0" . $gdd; };
$gmm = $gmm +1;
if (length($gmm)==1) { $gmm = "0" . $gmm; };
$gyy = 1900 + $gyy;
$db = "/iwrun/bak/db/archive/archive_$gyy" . "_$gmm" . "_$gdd";
print "$db\n";
if (!-e $db) {
	$db = "/iwrun/bak/db/archive/archive";
}	
print "$db\n";
return ($db,$gyy,$gmm,$gdd);
}
