<?php
# head
#include('./includes/antelope.php'); # GT attempt to remove Antelope dependency 9/3/15
include('./includes/getsubnets.php');
$mosaicurl = !isset($_REQUEST['mosaicurl'])? "" : $_REQUEST['mosaicurl'];	
$mosaicurl = urlencode($mosaicurl);
$MAXSUBNETLENGTH=12;
#$MAXSUBNETLENGTH=10;
#$subnet = !isset($_REQUEST['subnet'])? $subnets[0] : $_REQUEST['subnet'];
#$thumbs = !isset($_REQUEST['thumbs'])? "small" : $_REQUEST['thumbs'];
$page_title = "$subnet Spectrogram";
include('./includes/header.php');
include('./includes/daysPerMonth.php');
include('./includes/mosaicMakerTable.php');	
include('./includes/curPageURL.php');
include('./includes/findprevnextsubnets.php');
include('./includes/scriptname.php');
include('./includes/factorize.php');
include('./includes/recentSpectrograms.php');
include('./includes/sgramfilename2parts.php');

?>

<body>

<?php

	#$debugging = 1;
	$debugging = 0; error_reporting(E_ERROR | E_PARSE);


	# Set subnet
	$subnet = !isset($_REQUEST['subnet'])? $subnets[0] : $_REQUEST['subnet'];	
	if (  (isset($_REQUEST['year'])) && (isset($_REQUEST['month'])) && (isset($_REQUEST['day'])) && (isset($_REQUEST['hour'])) && (isset($_REQUEST['minute']))   ) {
	
		# Get date/time variables from URL variables, then create sgram filename from them
		$year =  $_REQUEST['year'];
		$month =  $_REQUEST['month'];
		$day =  $_REQUEST['day'];
		$hour = $_REQUEST['hour'];
		$minute = $_REQUEST['minute']; 
		$minute = floorminute($minute);
		$second = !isset($_REQUEST['second'])? 0 : $_REQUEST['second'];

		# set the number of minutes between spectrograms, i.e. minutes of data in a spectrogram (assuming no time overlap)	
		$numMins = !isset($_REQUEST['numMins'])? 10 : $_REQUEST['numMins'];	

		if ($minute != $_REQUEST['minute'] || $second > 0) { # rounded down
			list ($year, $month, $day, $hour, $minute, $secs) = addSeconds($year, $month, $day, $hour, $minute, 0, 600);
			$minute=floorminute($minute);
		}
	
		# For entry from the form, make sure it has correct number of digits
		$year = mkNdigits($year, 4);
		$month = mkNdigits($month, 2);
		$day = mkNdigits($day, 2);
		$hour = mkNdigits($hour, 2);
		$minute = mkNdigits($minute, 2); 

		#$sgram =  "$WEBPLOTS/$subnet/$year/$month/$day/".$year.$month.$day."T".$hour.$minute."00.png";	
		$sgram =  "$WEBPLOTS/$subnet/$year-$month-$day/".$subnet."_".$year.$month.$day."-".$hour.$minute.".png";	

	}
	else
	{
		# Get latest spectrogram for this subnet, and then form date/time variables from its filename
		$sgramfiles = recentSpectrograms($subnet, $WEBPLOTS, 1, 30);
		$sgram = $sgramfiles[0];
		list ($year, $month, $day, $hour, $minute) = sgramfilename2parts($sgram);
	}

		
	# Debugging
	if ($debugging == 1) {
		echo "<p>numMins = $numMins</p>\n";
		echo "<p>subnet = $subnet</p>\n";
		echo "<p>year = $year</p>\n";
		echo "<p>month = $month</p>\n";
		echo "<p>day = $day</p>\n";
		echo "<p>hour = $hour</p>\n";
		echo "<p>minute = $minute</p>\n";
		echo "<p>sgram = $sgram</p>\n";
		echo "<p>option = $option</p>\n";
		echo "<p>mosaicurl = $mosaicurl</p>\n";
		echo "<p>WEBPLOTS = $WEBPLOTS</p>\n";
		echo "<hr/>\n";
	}

	if ($mosaicurl != "") {
		echo '<input type="hidden" value="' . $mosaicurl . '" name="mosaicurl" />';
	}

	# Call up the appropriate spectrogram
	list ($previousSubnet, $nextSubnet) = findprevnextsubnets($subnet, $subnets);

	# make sure the date is valid
	if(!checkdate($month,$day,$year)){
		echo "<p>invalid date</p></body></html>";
	}
	else
	{
		# Time parameters of previous spectrogram and its path
		list ($pyear, $pmonth, $pday, $phour, $pminute, $psecs) = addSeconds($year, $month, $day, $hour, $minute, 0, -60*$numMins);
		$pminute=floorminute($pminute);
		#$previous_sgram = "$WEBPLOTS/$subnet/$pyear/$pmonth/$pday/".$pyear.$pmonth.$pday."T".$phour.$pminute."00.png";
		$previous_sgram = "$WEBPLOTS/$subnet/$pyear-$pmonth-$pday/".$subnet."_".$pyear.$pmonth.$pday."-".$hour.$minute.".png";	
		$previous_sgram_url = "$scriptname?subnet=$subnet&year=$pyear&month=$pmonth&day=$pday&hour=$phour&minute=$pminute&mosaicurl=$mosaicurl";

		# Time parameters of next spectrogram & its path
		list ($nyear, $nmonth, $nday, $nhour, $nminute, $nsecs) = addSeconds($year, $month, $day, $hour, $minute, 0, 60*$numMins);
		$nminute=floorminute($nminute);
		#$next_sgram = "$WEBPLOTS/$subnet/$nyear/$nmonth/$nday/".$nyear.$nmonth.$nday."T".$nhour.$nminute."00.png";
		$next_sgram = "$WEBPLOTS/$subnet/$nyear-$nmonth-$nday/".$subnet."_".$nyear.$nmonth.$nday."-".$hour.$minute.".png";	
		$next_sgram_url = "$scriptname?subnet=$subnet&year=$nyear&month=$nmonth&day=$nday&hour=$nhour&minute=$nminute&mosaicurl=$mosaicurl";

		######################### THINGS THAT DEPEND ON KISKA TIME, WHICH MAY NOT BE CURRENT TIME ####################### 	
		# The current time - albeit from Kiska which might be slow (or fast)
		#list ($cyear, $cmonth, $cday, $chour, $c1minute) = epoch2YmdHM(now());
		#$cminute = floorminute($c1minute);

		# Age of previous spectrogram
		#$pAge = timeDiff($pyear, $pmonth, $pday, $phour, $pminute, $psecs, $cyear, $cmonth, $cday, $chour, $cminute, 0);

		# Age of current spectrogram
		#$age = $pAge - 600;

		# Age of next spectrogram
		#$nAge = $age - 600;
		##################################################################################################################


		# Add sound file links & imageMap? 
		list($imgwidth, $imgheight, $imgtype, $imgattr) = getimagesize($sgram);
		$numsoundfiles = 0;
		$soundfileroot = str_replace(".png", "", $sgram);
		$soundfilelist = $soundfileroot . ".sound";
		if (file_exists($soundfilelist)) { 
			$soundfiles = array();
			$fh = fopen($soundfilelist, 'r');
			while(!feof($fh)) {
				#array_push($soundfiles, $WEBPLOTS . "/" . fgets($fh) );
				array_push($soundfiles, fgets($fh) );
			}
			fclose($fh);

			#$soundfiles = glob("$soundfileroot*.wav");
			$numsoundfiles = count($soundfiles)-1;
			#print "<p>height=$imgheight, width=$imgwidth, num=$numsoundfiles</p>\n";
			//echo "<p>Got $numsoundfiles sound files</p>";
			if ($numsoundfiles > 0) {
				$imageSizeX = $imgwidth - 57;
				$imageSizeX = $imgwidth - 23;
				$imageSizeY = $imgheight;
				#$imageTop = 45;
				$imageTop = 0;
				#$imageBottom = 97;
				$imageBottom = 35;
				$stationNum = 0;
				$panelSizeY = ($imageSizeY - $imageTop - $imageBottom) / $numsoundfiles;
				$xUpperLeft = 0;
				$xLowerRight = $imageSizeX;
				echo "<map name=\"mymap\" title=\"Click on spectrogram panels to play seismic data as sound (your web browser must be configured to play WAV files)\">\n";
				foreach ($soundfiles as $soundfile) {
					$yUpperLeft = ($imageTop + $panelSizeY * $stationNum);
					$yLowerRight = ($yUpperLeft + $panelSizeY);
					echo "<area shape=\"rect\" href=\"$soundfile\" target=\"sound\" coords=\"$xUpperLeft,$yUpperLeft  $xLowerRight,$yLowerRight\" alt=\"$soundfile\" />\n";
					$stationNum++;
				}
				echo "</map>\n";
			}
		}

	}
?>

<!-- Create a menu across the top -->
<div id="nav">
        <ul>
	<li title="Toggle menu to reselect time period based on absolute start time and number of hours" onClick="toggle_visibility('menu_absolutetime')">Absolute time</li>
  	<li class="subnetlink">
		<?php
			echo "<a title=\"Jump to the previous subnet along the arc, same time period\" href=\"$scriptname?subnet=$previousSubnet&year=$year&month=$month&day=$day&hour=$hour&minute=$minute&mosaicurl=$mosaicurl\">&#9650 ".substr($previousSubnet,0,$MAXSUBNETLENGTH)."</a>\n";
		?>
	</li>
  	<li class="subnetpulldown">
		<?php
			# Subnet widgit
                  	echo "<select title=\"Jump to a different subnet\" onchange=\"window.open('?subnet=' + this.options[this.selectedIndex].value + '&year=$year&month=$month&day=$day&hour=$hour&minute=$minute&mosaicurl=$mosaicurl', '_top')\" name=\"subnet\">\n";
			echo "\t\t\t<option value=\"$subnet\" SELECTED>".substr($subnet,0,$MAXSUBNETLENGTH)."</option>\n";
			foreach ($subnets as $subnet_option) {
				print "\t\t\t<option value=\"$subnet_option\">".substr($subnet_option,0,$MAXSUBNETLENGTH)."</option>\n";
			}
			print "\t\t</select>\n";
		?>
	</li>
  	<li class="subnetlink">
		<?php
			echo "<a title=\"Jump to the next subnet along the arc, same time period\" href=\"$scriptname?subnet=$nextSubnet&year=$year&month=$month&day=$day&hour=$hour&minute=$minute&mosaicurl=$mosaicurl\">&#9660 ".substr($nextSubnet,0,$MAXSUBNETLENGTH)."</a>\n";
		?>
	</li>
  	<li>
		<?php
			echo "<a title=\"Jump back in time 10 minutes\" href=\"$previous_sgram_url\">&#9668 Earlier</a>\n";
		?>
	</li>
  	<li>
		<?php
			echo "<a title=\"Jump forward in time 10 minutes\" href=\"$next_sgram_url\">&#9658 Later</a>\n";
		?>
	</li>
  	<li>
		<?php
		        echo "<a title=\"Jump to the most recent spectrogram for $subnet\" href=\"$scriptname?subnet=$subnet&mosaicurl=$mosaicurl\">Latest</a>\n";
		?>
	</li>
	<li title="Return to last spectrogram mosaic. This is useful when performing twice-daily seismicity checks.">
		<?php
                	$spectrogram_epoch = strtotime("$year-$month-$day $hour:$minute:00");
                	list ($syear, $smonth, $sday, $shour, $sminute) = epoch2YmdHM($spectrogram_epoch - 3600);
			if ($mosaicurl == "") {
                		print "<a href=\"mosaicMaker.php?subnet=$subnet&year=$syear&month=$smonth&day=$sday&hour=$shour&minute=$sminute&numhours=2&numMins=$numMins\">Mosaic</a>\n";
			} else {
                		print "<a href=\"".urldecode($mosaicurl)."\">Mosaic</a>\n";
			}
		?>
	</li>

        </ul>
</div>
<p/>

<form method="get" id="menu_absolutetime" class="hidden">

        <table class="center" border=0>
                <?php
                        echo "<tr>\n";

                                echo "\t\t\t<td title=\"Enter end time for the spectrogram (UTC)\"><b>End time: </b>";
						
                                                # Year widgit
                                                echo "Year:";
                                                echo "<input type=\"text\" name=\"year\" value=\"$year\" size=\"4\" >";

                                                # Month widgit
                                                echo "Month:";
                                                echo "<input type=\"text\" name=\"month\" value=\"$month\" size=\"2\">";

                                                # Day widgit
                                                echo "Day:";
                                                echo "<input type=\"text\" name=\"day\" value=\"$day\" size=\"2\" >";

                                                # Hour widgit
                                                echo "Hour:";
                                                echo "<input type=\"text\" name=\"hour\" value=\"$hour\" size=\"2\" >";

                                                # Minute widgit
                                                echo "Minute:";
                                                echo "<select name=\"minute\">";
                                                echo "<option value=\"$minute\" SELECTED>$minute</option>";
						for ($ominute=0; $ominute<60; $ominute = $ominute + $numMins) {
                                                        printf("<option value=\"%02d\">%02d</option>\n",$ominute,$ominute);
                                                }
                                                print "</select>";


                                # end this cell
                                echo "</td>\n";


                        	# Submit button
				echo "<input type=\"hidden\" name=\"subnet\" value=\"$subnet\">\n";
            			print "\t\t\t<td title=\"Redraw spectrogram with end time given here\"><input type=\"submit\" name=\"submit\" value=\"Go\"></td>\n";

                	echo "\t\t</tr>\n";

                ?>
        </table>

</form>
<p/>
<div id="spectrogram">
<?php
 
	# CURRENT SGRAM
	echo "<table class=\"center\" border=0 width=400px>\n";
        $utchhmm_start  = sprintf("%02d:%02d", $phour, $pminute);
        date_default_timezone_set('UTC');
        $utcepoch_start = mktime($phour,$pminute,0,$pmonth,$pday,$pyear);
        $utcepoch_end = mktime($hour,$minute,0,$month,$day,$year);
        date_default_timezone_set('US/Alaska');
        $localtime = localtime($utcepoch_start, true); # Cannot just use t
        $localtime_end = localtime($utcepoch_end, true); # Cannot just use t
        $localtimelabel = sprintf("%4d/%02d/%02d %02d:%02d - %02d:%02d",$localtime[tm_year]+1900,$localtime[tm_mon]+1,$localtime[tm_mday],$localtime[tm_hour],$localtime[tm_min],$localtime_end[tm_hour],$localtime_end[tm_min]);

	echo "\t<tr><td title=\"Spectrogram time range in UTC. Equivalent local time range: $localtimelabel\"><h1>$subnet $pyear/$pmonth/$pday $phour:$pminute - $hour:$minute</h1></td></tr>\n";	
	$sgramFound = 0;
	if (file_exists($sgram)) {
		if (filesize($sgram) > 0) {
			$sgramFound = 1;
			echo "\t<tr>";
			echo "<td>\n";
			echo "<img usemap=\"#mymap\" src=\"$sgram\" />";
			#$oldsgram = "plots2/$subnet/$year/$month/$day/".basename($sgram);
			#if (file_exists($oldsgram)) {
			#	echo "</td><td>\n";
			#	echo "<img usemap=\"#mymap\" src=\"$oldsgram\" />";
			#} else {
			#	#echo "$oldsgram not found<br/>\n";
			#}
			echo "</td>\n";

			# Colorbar div
			echo "<td>\n";
			echo "<div id=\"colorbar\" class=\"hidden\">\n";
			#echo "<br/><img src=\"images/iceweb_spectrogram_colorbar.png\" />";
			echo "<br/><img src=\"images/colorbar.png\" />";
			echo "</div>\n";
			echo "</td>\n";
			echo "</tr>\n";


		}
	}

	if ($sgramFound == 0) {
		echo "\t<tr><td>\n";
		echo "<h3>Sorry, that spectrogram image is not available.</h3><br/>";

		# Generate list of recent spectrograms
		$sgramfiles = recentSpectrograms($subnet, $WEBPLOTS, 24, 7);
		echo "<h3>The most recent spectrograms are:</h3><br/>\n";
		foreach ($sgramfiles as $sgramfile) {
			list ($ryear, $rmonth, $rday, $rhour, $rminute, $rsubnet) = sgramfilename2parts($sgramfile);
			$sgramfileurl="$scriptname?subnet=$subnet&year=$ryear&month=$rmonth&day=$rday&hour=$rhour&minute=$rminute&mosaicurl=$mosaicurl";
			$size = filesize($sgramfile);
			if ($size > 0) {
				echo "<a href=\"$sgramfileurl\">$ryear/$rmonth/$rday $rhour:$rminute (size: $size bytes)</a><br/>\n";
			} else {
				echo "$ryear/$rmonth/$rday $rhour:$rminute (size: $size bytes)<br/>\n";
			}
		}	
		echo "</td></tr>\n";
	}
	?>

	<!-- Buttons -->
	<tr><td>
		<table border=0 width=580><tr><td>
			<div class="button" title="Permanent link to this spectrogram" onClick="toggle_visibility('show_url')" style="width:100px;">Permalink</div><br/>
			<!-- Here is the colorbar button -->
			<a class="button" href="#" onclick="toggle_visibility('colorbar');" style="width:100px;">Colorbar</a><br/>
			<?php
				# Diagnostic data		
				$sgramtxtfile = str_replace("png", "txt", $sgram);
				if ( file_exists($sgramtxtfile) ) {
					printf("<a class=\"button\" href=$sgramtxtfile target=\"diagnostics\" style=\"width:100px;\">Diagnostics</a>\n"); 
				};
				echo "</td>\n";

				# Branding
				include("includes/branding.php");
				echo "</tr>";

				# Bugs/Issues
				#printf("<a class=\"button\" href=\"https://github.com/giseislab/TreMoR/issues\" target=\"bugs\">Bugs</a>\n"); 

				# Comments
				#printf("<a class=\"button\" href=\"mailto:gthompson@alaska.edu?Subject=Spectrograms\">Send Mail</a>\n");
	
				# About
				#printf("<a class=\"button\" href=\"includes/about.php\" target=\"about\">About</a>\n"); 
			?>
		</td></tr></table>
	</td></tr>
</table>
<br/>
<div id="show_url" class="hidden">
	<table class="center" border=0><tr><td align="center">
		<?php
			# Show URL
			$link = curPageURL();
			$loc = strpos($link, "mosaicurl");
			if ($loc !== FALSE) {
				$link = substr($link, 0, $loc - 1);
			}
			echo "The permanent link to this web page is: <br/><font color='blue'>$link</font><br/n> ";
                        $link = urlencode($link);
                        $url = '<p/><table border=0 title="Create an AVO log post with this URL embedded in it"><tr><td><a class="button" href="https://www.avo.alaska.edu/admin/logs/add_post.php?url=' . $link . '" target=\"logs\">Add log post</a></td></tr></table>';
                        echo "$url\n";
		?>
	</td></tr></table>
</div>
</body>
</html>

