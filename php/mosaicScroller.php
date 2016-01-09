<?php

# Standard XHTML header
$page_title = "Spectrogram Mosaic Scroller";
$css = array( "css/newspectrograms.css", "css/mosaicMaker.css", "css/select_multiple" );
$googlemaps = 0;
$js = array('toggle_menus.js', 'toggle_visibility.js');
include('./includes/header.php');

# header files
include('./includes/getsubnets.php');
include('./includes/daysPerMonth.php');
include('./includes/mosaicMakerTable.php');	
include('./includes/curPageURL.php');
#include('./includes/findprevnextsubnets.php');
include('./includes/scriptname.php');
include('./includes/factorize.php');

$subnetsToUse = !isset($_REQUEST['subnetsToUse'])? $subnets[0] : $_REQUEST['subnetsToUse'];
$thumbs = !isset($_REQUEST['thumbs'])? "small" : $_REQUEST['thumbs'];
?>

<body>

<?php

	# global variables
	$debugging = 1;
	$scriptname = scriptname();

	# Set date/time now
	$timenow = now(); ################# KISKA TIME #################### 
	$currentYear = epoch2str($timenow, "%Y");
	$currentMonth = epoch2str($timenow, "%m");
	$currentDay = epoch2str($timenow, "%d");
	$currentHour = epoch2str($timenow, "%H");
	$currentMinute = epoch2str($timenow, "%i");
	$currentMinute = epoch2str($timenow, "%M");
	$currentSec = epoch2str($timenow, "%S");

	# Set convenience variables from CGI parameters
        if (   (isset($_REQUEST['starthour'])) && (isset($_REQUEST['endhour'])) ) {

		# Called with starthour, endhour

		# Although this script will accept URL variables starthour and endhour, here we translate them into
		# year/month/day hour:minute, and we also change the URL PHP thinks this page has, so posts real time to log posts 
		$starthour = $_REQUEST['starthour'];
        	$endhour = !isset($_REQUEST['endhour'])? 0 : $_REQUEST['endhour'];
                if ($starthour < $endhour) {
			$tmphour = $endhour;
			$endhour = $starthour;
			$starthour = $tmphour;
		} 
		$timestart = now() - $starthour * 3600; ###### KISKA TIME ################################################
        	list($year, $month, $day, $hour, $minute) = epoch2YmdHM($timestart);
        	$minute=floorminute($minute);
        	$numhours = $starthour - $endhour;
		$_REQUEST['year'] = $year;
		$_REQUEST['month'] = $month;
		$_REQUEST['day'] = $day;
		$_REQUEST['hour'] = $hour;
		$_REQUEST['minute'] = $minute;
		$_REQUEST['numhours'] = $numhours;

	} else {

		# Called with year/month/day hour:minute, or with nothing. In the latter case, we default to last 2 hours
		$timestart = now() - 2 * 3600; ###### KISKA TIME ################################################
        	list($year, $month, $day, $hour, $minute) = epoch2YmdHM($timestart);

		$year = !isset($_REQUEST['year'])? $year : $_REQUEST['year'];
		$month = !isset($_REQUEST['month'])? $month : $_REQUEST['month'];
		$day = !isset($_REQUEST['day'])? $day : $_REQUEST['day'];
		$hour = !isset($_REQUEST['hour'])? $hour : $_REQUEST['hour'];
		$minute = !isset($_REQUEST['minute'])? $minute : $_REQUEST['minute'];
        	$minute=floorminute($minute);
		$numhours = !isset($_REQUEST['numhours'])? 2 : $_REQUEST['numhours'];
        	$starttime = str2epoch("$year/$month/$day $hour:$minute:00");
        	$starthour = (($timenow - $starttime) / 3600);
        	$endhour   = (($timenow - $starttime) / 3600) - $numhours;

	}
		
	# Degugging
	if ($debugging == 1) {
		#var_dump($_REQUEST);
		var_dump($_GET);
		foreach ($subnetsToUse as $thisSubnet) {
			print "<p>subnet=$thisSubnet</p>\n";
		}
		print "<p>Mosaic time: $year/$month/$day $hour:$minute</p>\n";
		print "<p>Current time: $currentYear/$currentMonth/$currentDay $currentHour:$currentMinute</p>\n";
		print "<p><a href=".curPageURL().">url=".curPageURL()."</a></p>\n";
		echo "<hr/>\n";
	}

	# Early and later mosaic time windows
        $numseconds = $numhours * 3600;
        list ($pyear, $pmonth, $pday, $phour, $pminute, $psecs) = addSeconds($year, $month, $day, $hour, $minute, 0, -$numseconds);
        $pminute=floorminute($pminute);
        list ($nyear, $nmonth, $nday, $nhour, $nminute, $nsecs) = addSeconds($year, $month, $day, $hour, $minute, 0, $numseconds);
        $nminute=floorminute($nminute);
?>	

<a name="top"></a>


<!-- Create a menu across the top -->
<div id="nav">
        <ul>
	<li title="Toggle menu to reselect time period based on relative start and end time"  onClick="toggle_menus('menu_hoursago')">Relative time</li>
	<li title="Toggle menu to reselect time period based on absolute start time and number of hours" onClick="toggle_menus('menu_absolutetime')">Absolute time</li>

        <li class="subnetpulldown">
                <form id="subnetform" method="get" action="mosaicScroller.php">
                <select multiple="true" title="Select subnets" name="subnetsToUse[]" >
                <?php
                        foreach ($subnets as $subnet_option) {
                                print "<option value=\"$subnet_option\">$subnet_option</option> ";
                        }
                ?>
                </select>
                <input type="submit" value="Submit" name="submit_button"></p>
                </form>
        </li>

  	<li>
		<?php
         		echo "<a title=\"Jump back in time $numhours hours\" href=\"$scriptname?subnetsToUse[]=$subnetsToUse&year=$pyear&month=$pmonth&day=$pday&hour=$phour&minute=$pminute&numhours=$numhours\">&#9668 Earlier</a>\n";
		?>
	</li>
  	<li>
		<?php
         		echo "<a title=\"Jump forward in time $numhours hours\" href=\"$scriptname?subnetsToUse[]=$subnetsToUse&year=$nyear&month=$nmonth&day=$nday&hour=$nhour&minute=$nminute&numhours=$numhours\">&#9658 Later</a>\n";
		?>
	</li>
  	<li>
		<?php
		        echo "<a title=\"Redraw spectrogram mosaic to end at current time\" href=\"$scriptname?subnetsToUse[]=$subnetsToUse&starthour=$numhours&endhour=0\">Now</a>\n";
		?>
	</li>
	<li onClick="toggle_visibility('show_url')" title="Permanent link to this spectrogram mosaic">Permalink</li>
        </ul>
</div>
<p/>
<div id="show_url" class="hidden">
	<table class="center" border=0><tr><td align="center">
		<?php
			# Show URL
			$link = curPageURL();
			# not needed here since plotsPerRow not an agurmnent
			#$loc = strpos($link, "plotsPerRow");
			#if ($loc !== FALSE) {
			#	$link = substr($link, 0, $loc - 1);
			#}
			echo "The permanent link to this web page is: <br/><font color='blue'>$link</font><br/n> ";
                        $link = urlencode($link);
                        $url = '<p/><table border=0 title="Create an AVO log post with this URL embedded in it"><tr><td><a class="button" href="https://www.avo.alaska.edu/admin/logs/add_post.php?url=' . $link . '" target=\"logs\">Add log post</a></td></tr></table>';
                        echo "$url\n";
		?>
	</td></tr></table>

</div>
<p/>

<?php
	$plotMosaic = 0; 
	# make sure the date is valid
	if(!checkdate($month,$day,$year)){
		echo "<p>invalid date</p>";
 	}
	else
	{
		$plotMosaic = 1;
	}
?>


<form method="get" id="menu_hoursago" class="hidden">
	<table class="center" border=1>
		<?php
			echo "<tr>\n";
			echo "<td>Hours ago:&nbsp;\n";
			# Start hour widgit
		        printf("<i>Start</i><input title=\"How many hours ago the mosaic time period should start\" type=\"text\" name=\"starthour\" value=\"%.0f\" size=\"4\">",$starthour);

			# End hour widgit
		        printf("<td><i>End</i><input title=\"How many hours ago the mosaic time period should end\" type=\"text\" name=\"endhour\" value=\"%.0f\" size=\"4\">",$endhour);

			# Submit & Reset buttons
                        echo "<input type=\"hidden\" name=\"subnetsToUse[]\" value=\"$subnetsToUse\">\n";
			print "<input title=\"Redraw spectrogram mosaic based on the start and end hours ago here\" type=\"submit\" name=\"submit\" value=\"Go\"></td>\n";
			echo "</tr>\n";
		?>
	</table>
</form>

<form method="get" id="menu_absolutetime" class="hidden">

        <table class="center" border=1>
                <?php
                        echo "<tr>\n";

                                echo "\t\t\t<td title=\"Enter start time for the spectrogram mosaic\" >Start time:&nbsp;";
						echo "<i>";	
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
                                                $minutes = array("00", "10", "20", "30", "40", "50");
                                                foreach ($minutes as $minute_option) {
                                                        print "<option value=\"$minute_option\">$minute_option</option>\n";
                                                }
                                                print "</select>";
						echo "</i>";	


                                # end this cell
                                echo "</td>\n";

				# Number of hours widgit
				echo "<td title=\"Enter the number of hours for the spectrogram mosaic. End time will be start time plus this many hours\">Number of hours:\n";
				echo "<input type=\"text\" name=\"numhours\" value=\"$numhours\" size=\"2\"> ";
				echo "</td>\n";

                                # Submit button
                                echo "<input type=\"hidden\" name=\"subnetsToUse[]\" value=\"$subnetsToUse\">\n";
                                print "\t\t\t<td title=\"Redraw spectrogram mosaic with start time and number of hours given here\"><input type=\"submit\" name=\"submit\" value=\"Go\"></td>\n";

                        echo "\t\t</tr>\n";

                ?>
        </table>

</form>

<br/>
<!-- <div class="center" id="mosaic"> -->

<?php
	if ($plotMosaic==1) {
		foreach ($subnetsToUse as $subnet)
		{
			$title = mosaicMaker($subnet, $year, $month, $day, $hour, $minute, $numhours, $numhours*6, $WEBPLOTS, $thumbs, 0);
		}
	}
	else
	{
		echo "<h1>Welcome to the Spectrogram Mosaic Scoller!</h1><p>This page provides links to PNG files of 10-minute spectrograms pre-generated by the \"TreMoR\" system.</p>";
	}
?>

<a class="button" href="#top" style="float:right;">Top</a>

</body>
</html>

