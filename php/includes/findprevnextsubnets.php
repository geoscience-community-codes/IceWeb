<?php
function findprevnextsubnets($subnet, $subnets)  {
	#print_r($subnets);
	#print "subnet = $subnet\n";
	# set previous subnet & next subnet
	$i = array_search($subnet, $subnets);
	#print "i = $i\n";
	if ($i > 0) {
		$previousSubnet = $subnets[$i - 1];
	}		
	else	
	{ 
		$previousSubnet = end($subnets);
	}
		
	if ($i < count($subnets) - 1) {
		$nextSubnet = $subnets[$i + 1];
	}
	else
	{
		$nextSubnet = $subnets[0];
	}
	#print "previous = $previousSubnet\n";
	#print "next = $nextSubnet\n";
	return array($previousSubnet, $nextSubnet);
}
?>
