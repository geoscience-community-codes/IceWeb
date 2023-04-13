#! /usr/bin/perl -w
use lib "$ENV{ANTELOPE}/data/perl"; # antelope-perl interface
use Datascope;
$secsperday = 3600*24;
$d=$ARGV[1];
($gsec,$gmin,$ghour,$gdd,$gmm,$gyy,$gwday,$gyday,$gisdst)=gmtime(time+$d*$secsperday);
		if (length($gdd)==1) { $gdd = "0" . $gdd; };
		$gmm = $gmm +1;
		if (length($gmm)==1) { $gmm = "0" . $gmm; };
		if ($d>-2) {
			$db = "/iwrun/op/db/archive/archive";
		}
		else
		{
			$db = "/iwrun/op/db/archive/archive_$gyy$gmm$gdd";
		};
		if ($gyy > 50) { $gyy = "19" . $gyy;} else { $gyy = "20" . $gyy };
$dbheli = "/opt/antelope/4.1/bin/dbheli";
$sta = $ARGV[0];
$chan = "SHZ";
$stime = str2epoch("$gmm/$gdd/$gyy 00:00");
$twin = 3600;
$nlines = 24;
$scale = 500;
$filterstr = '"BW 0.8 5 5.0 5"';
system("mkdir /home/iceweb/HELI_CODE/$sta");
$psfile = "/home/iceweb/HELI_CODE/$sta/$sta$gmm${gdd}.ps";
system ("$dbheli $db $sta $chan $stime $twin $nlines $scale -f $filterstr -ps $psfile\n");
