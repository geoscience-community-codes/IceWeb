#!/usr/bin/perl
require("/home/glenn/ICEWEB/SYSTEM_1/perl_iceweb_paths");
#$UTILS="$RESPONSE/UTILITIES";
$UTILS="/home/iceweb/DATA/RESPONSE";
unlink("$UTILS/transfer_VNSS.in");
$F=0;
foreach $sta (@ARGV) {
	system("cat /usr/hypoe/caldata/caldata.prm | grep 999999 | grep $sta > $UTILS/data.out");
	if (-z "data.out") {
		printf "Station $sta cannot be used for IceWeb - there is no calibration data\n";
		$F=1;
	}
	system("$UTILS/checkiceworm $sta > $UTILS/ice.out");
	system("cat $UTILS/ice.out | grep Failed > $UTILS/fred.out");
	if (-z "$UTILS/fred.out") {
		printf "Station $sta is suitable for IceWeb\n";
		system("tail -1 $UTILS/data.out >> $UTILS/transfer.in");
	}
	else
	{
		printf "Station $sta cannot be used for IceWeb - it is not on Iceworm\n";
		$F=1;
	}
}
if ($F==0) {
	printf "\nNow run the matlab function  create_transfer_functions\n";
}
system("rm $UTILS/*.out");


	
