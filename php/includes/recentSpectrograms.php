<?php
function recentSpectrograms($subnet, $WEBPLOTS, $MINFILES, $MAXDAYS)
{
	# Loop from today and over the $MAXDAYS last days, until at least $MINFILES spectrograms found
	$filesarray = array();
	$time = time()+1000; # check 1000s ahead in case time is slow on kiska
	$daysago = 0;
	do {
		list ($year, $month, $day, $hour, $minute) = epoch2YmdHM($time);
		$minute = floorminute($minute);
		#$filepath = "$WEBPLOTS/$subnet/$year/$month/$day/2*.png";
		$filepath = "$WEBPLOTS/$subnet/$year-$month-$day/$subnet"."_2*.png";
		$thisarray = glob($filepath);
		rsort($thisarray);
		if (count($thisarray) > 0) {
			$filesarray = array_merge($filesarray, $thisarray);
		}
		$time = $time - 86400;
		$daysago++;
	} while (count($filesarray) < $MINFILES && $daysago < $MAXDAYS);
	rsort($filesarray);
	$nonzerofilesarray = array();
	foreach ($filesarray as $myfile) {
		$size = filesize($myfile);
		if ($size>0) {
			$nonzerofilesarray[] = $myfile;
			#print "$myfile<br/>\n";
		}
	}
		
	$nonzerofilesarray = array_slice($nonzerofilesarray, 0, $MINFILES);
	return $nonzerofilesarray;
}

?>
