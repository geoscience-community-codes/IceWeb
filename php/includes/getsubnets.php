<?php
$WEBPLOTS = "spectrograms"; 
$subnets = array();
$subnetslist = "config/subnetslist.txt";
if (file_exists($subnetslist)) { 
	#print "$subnetslist exists\n";
	if ($fp = fopen($subnetslist, "r")) {
		while (!feof($fp)) {
			#print "Reading next subnet...\n";
			$thissubnet = trim(fgets($fp));
			if ($thissubnet != "") {
				array_push($subnets, $thissubnet);
			}
		}
		#print "EOF reached\n";
		fclose($fp);
	} else {
		#print "Invalid file handle\n";
	}
} else {
	echo "$subnetslist does not exist</html>\n";
}
#print_r($subnets);
#print count($subnets);

?>
