<?php
function mosaicMaker($numMins, $subnet, $year, $month, $day, $hour, $minute, $numhours, $plotsPerRow, $WEBPLOTS, $thumbs, $includeHeader) {
	#$epochnow = now();  # antelope
	$epochnow = time();

        # generate the epoch time for the start date/time requested
        $startepoch = mktime($hour, $minute, 0, $month, $day, $year); # get local/utc conversion issues
        #$startepoch = str2epoch("$year/$month/$day $hour:$minute:00"); # antelope

       	# work out the difference in seconds
        $starthour = (($epochnow - $startepoch) / 3600);
        $endhour   = (($epochnow - $startepoch) / 3600) - $numhours;

	#if ($starthour < 0) {
	#	$starthour = 0;
	#}

	#if ($endhour < 0) {
	#	$endhour = 0;
	#}

	#$startepoch = now() - $starthour * 60 * 60 ;
	#list ($year, $month, $day, $hour, $minute) = epoch2YmdHM($startepoch);

	$stopepoch = $epochnow - $endhour * 60 * 60 ;
	list ($year_stop, $month_stop, $day_stop, $hour_stop, $minute_stop) = epoch2YmdHM($stopepoch);

	list ($year_now, $month_now, $day_now, $hour_now, $minute_now) = epoch2YmdHM($epochnow);

	$webpagetitle = sprintf("%s %4d/%02d/%02d %02d:%02d",$subnet, $year, $month, $day, $hour, $minute );
	if ($includeHeader) {
		printf("<h1 title=\"The start date/time of the spectrogram mosaic (UTC)\" align=\"center\">%s %4d/%02d/%02d %02d:%02d (%dh %02dm ago)</h1>\n",$subnet, $year, $month, $day, $hour, $minute, $starthour, (60*$starthour)%60 );
	} else {
		printf("<h1 title=\"Start: %4d/%02d/%02d %02d:%02d UTC (%dh %02dm ago)\" align=\"center\">%s</h1>\n", $year, $month, $day, $hour, $minute, $starthour, (60*$starthour)%60, $subnet );
		
	}

	#echo "<table class=\"center\" id=\"mosaictable\">\n";
	echo "<table class=\"center\" >\n";

	$c = 0;
	$latestAge = "?";
	$firstRow = 1;
	$oldhhmm = "";

	for ( $time = $startepoch + ($numMins * 60); $time < $stopepoch + $numMins * 60; $time += $numMins * 60) {

		# Get the end date and time for the current image
		list ($year, $month, $day, $hour, $minute) = epoch2YmdHM($time);
		$floorminute = floorminute($minute);
		#$timestamp = sprintf("%04d%02d%02dT%02d%02d",$year ,$month, $day, $hour, $floorminute) . "00";
		$timestamp = sprintf("%04d%02d%02d-%02d%02d",$year ,$month, $day, $hour, $floorminute);

		# Create labels for end hour/minute
		$hhmm = sprintf("%02d:%02d", $hour, $floorminute);

		# Get the start date and time for the current image
		list ($syear, $smonth, $sday, $shour, $sminute) = epoch2YmdHM($time - $numMins * 60);
		$floorsminute= floorminute($sminute);

		# Create labels for start hour/minute
		$rowstarthhmm  = sprintf("%02d:%02d", $shour, $floorsminute);
		#date_default_timezone_set('UTC');
		$floorepochUTC = mktime($shour,$sminute,0,$smonth,$sday,$syear);
		#date_default_timezone_set('US/Alaska');
		$localtime = localtime($floorepochUTC,true); # Cannot just use time (see above vairable) here since it is now "floored"
		$rowstartlocalhhmm = sprintf("%4d/%02d/%02d %02d:%02d",$localtime['tm_year']+1900,$localtime['tm_mon']+1,$localtime['tm_mday'],$localtime['tm_hour'],$localtime['tm_min']); 
		if ($oldhhmm == "") {
			$oldhhmm = $rowstarthhmm." - ";
		}	
		# Set the link to the big image file
		$sgramphplink = "sgram10min.php?year=$year&month=$month&day=$day&hour=$hour&minute=$floorminute&subnet=$subnet&mosaicurl=".urlencode(curPageURL());

		# work out age of this latest data in this image
		if (($epochnow - $time) < 24*60*60) {
			$now = strtotime("$year_now-$month_now-$day_now $hour_now:$minute_now:00");
			$tim = strtotime("$year-$month-$day $hour:$floorminute:00");
			$ageSecs = $now - $tim;
			$ageHours = floor($ageSecs / 3600);
			$ageMins = floor(($ageSecs - (3600 * $ageHours)) / 60);
			$ageStr = sprintf("%dh%02dm", $ageHours, $ageMins);

			if ($ageSecs < 0) {
				$ageHours = floor((-$ageSecs) / 3600);
				$ageMins = floor(((-$ageSecs) - (3600 * $ageHours)) / 60);
				$ageStr = sprintf("-%dh%02dm", $ageHours, $ageMins);

			}
		}

		# (ROW STARTS HERE)
		if (($c % $plotsPerRow)==0) {
			$rowFinished = 0;
			#echo "<br/>\n";
			if ($firstRow==0) {
				echo "<tr class=\"mosaicblankrow\"><td>&nbsp;</td></tr>\n";
			} else {
				$firstRow = 0;
			}
			#echo "<tr class=\"sideborder\" ><td class=\"time\" title=\"Start time for this row (UTC). Local time is $rowstartlocalhhmm\">$rowstarthhmm</td>\n";
			echo "<tr><td class=\"time\" title=\"Start time for this row (UTC). Local time is $rowstartlocalhhmm\">$rowstarthhmm</td>\n";
		}

		# CELL STARTS HERE 			
		#$small_sgram = "$WEBPLOTS/$subnet/$year/$month/$day/$thumbs"."_$timestamp.png";
		#$big_sgram = "$WEBPLOTS/$subnet/$year/$month/$day/$timestamp.png";
		$big_sgram = "$WEBPLOTS/$subnet/$year-$month-$day/$subnet"."_".$timestamp.".png";
		$small_sgram = "$WEBPLOTS/$subnet/$year-$month-$day/$subnet"."_".$timestamp."_thumb.png";
		if (file_exists($small_sgram)) {
			$latestAge = $ageStr;
			echo "<td title=\"$oldhhmm$hhmm\" class=\"tdimg\"><a href=$sgramphplink><img src=$small_sgram></a></td>\n";
		} else {
			if (file_exists($big_sgram)) {
				if (filesize($big_sgram)==0) {
					echo "<td title=\"An attempt has been made to load data for this timeperiod.\" class=\"tdimg\"><a href=$sgramphplink><img src=\"images/nothumbnail.png\"></a></td>\n";
				} else {
					echo "<td title=\"No thumbnail image produced $small_sgram\" class=\"tdimg\"><a href=$sgramphplink><img src=\"$big_sgram\" width=150 height=198></a></td>\n";
				}
			} else {
				echo "<td title=\"No spectrogram image file found $big_sgram $small_sgram\" class=\"tdimg\"><a href=$sgramphplink><img src=\"images/nothumbnail.png\"></a></td>\n";
			}
		}

		# CELL ENDS HERE

		if (($c % $plotsPerRow)==($plotsPerRow-1)) {
			# ROW ENDS HERE
			#date_default_timezone_set('UTC');
			$floorepochUTC = mktime($hour,$minute,0,$month,$day,$year);
			#date_default_timezone_set('US/Alaska');
			$localtime = localtime($floorepochUTC,true); # Cannot just use time (see above vairable) here since it is now "floored"
			$rowendlocalhhmm = sprintf("%4d/%02d/%02d %02d:%02d",$localtime['tm_year']+1900,$localtime['tm_mon']+1,$localtime['tm_mday'],$localtime['tm_hour'],$localtime['tm_min']); 
			echo "<td class=\"time\" title=\"End time for this row (UTC). Local time is $rowendlocalhhmm\">$hhmm</td>\n";
			$rowFinished = 1;

		}
		

		$c++;

		$oldhhmm = "$hhmm - ";
	}

	if ($rowFinished == 0) {
		echo "<td></td></tr>\n";
	}
	echo "</table>\n";

	if ($includeHeader) {
		printf("<h1 title=\"The end date/time of the spectrogram mosaic (UTC)\" align=\"center\">%s %4d/%02d/%02d %02d:%02d (%dh %02dm ago)</h1>\n",$subnet, $year, $month, $day, $hour, $minute, $endhour, (60*$endhour)%60 );
	}
	$webpagetitle .= sprintf("- %4d/%02d/%02d %02d:%02d",$year, $month, $day, $hour, $minute );

	return $webpagetitle;

}

function epoch2YmdHM($e) {
	$numMins=10;
	#$year = epoch2str($e, "%Y", "UTC");
	#$month = epoch2str($e, "%m", "UTC");
	#$day = epoch2str($e, "%d", "UTC");
	#$hour = epoch2str($e, "%H", "UTC");
	#$minute = epoch2str($e, "%M", "UTC");
	$year = date('Y', $e);
	$month = date('m', $e);
	$day = date('d', $e);
	$hour = date('H', $e);
	$minute = date('i', $e);

	return array($year, $month, $day, $hour, $minute);
}

function floorMinute($minute) {
	$numMins=10;
	$floorminute = floor($minute / $numMins) * $numMins;
	$floorminute = mkNdigits($floorminute, 2);
	return $floorminute;
} 

function mkNdigits($str, $N) {
	while (strlen($str) < $N) 
	{
		$str = "0".$str;
	}
	return $str;
}
function addSeconds($y,$m,$d,$h,$i,$s,$secsToAdd) {
	$t = strtotime("$y/$m/$d $h:$i:$s");
	$t = $t + $secsToAdd;
	$y = date('Y', $t);
	$m = date('m', $t);
	$d = date('d', $t);
	$h = date('H', $t);
	$i = date('i', $t);
	$s = date('s', $t);
	return array($y, $m, $d, $h, $i, $s);
}
function timeDiff($y1, $m1, $d1, $h1, $i1, $s1, $y2, $m2, $d2, $h2, $i2, $s2) {
	$t1 = strtotime("$y1/$m1/$d1 $h1:$i1:$s1");
	$t2 = strtotime("$y2/$m2/$d2 $h2:$i2:$s2");
	return ($t2 - $t1);


}
?>
	
