#!/usr/bin/perl

use lib  "/home/iceweb/ICEWEB_UTILITIES";
use iceweb_perl_utilities qw(get_time);

($year,$mon,$day,$hour,$min)=get_time("ut",0);
#$year = 2000;
#$mon = 12;
#$day = 31;
#$hour = 12;
#$min = 0;

print "$year/$mon/$day $hour:$min\n";

@dayspermonth = (0,31,28,31,30,31,30,31,31,30,31,30,31);
$m=0;
#$yday=$day-1;
$yday=$day;
while ($mon>$m) {
        $yday=$yday+$dayspermonth[$m];
        $m++;
print "$yday\n";
};

$Jan_01_1998=729756;
$dnum=$Jan_01_1998+$yday+($year-1998)*365+$hour/24+$min/(24*60);
print "$dnum\n";

$dnum = substr($dnum,0,10);
print "$dnum\n";
