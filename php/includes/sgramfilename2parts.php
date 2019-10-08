<?php
function sgramfilename2parts($sgram)
{
		$datetime = basename($sgram);
		$year = substr($datetime, 0, 4);
		$month = substr($datetime, 4, 2);
		$day = substr($datetime, 6, 2);
		$hour = substr($datetime, 9, 2);
		$minute = substr($datetime, 11,2);

		return array($year, $month, $day, $hour, $minute); 
}
?>
