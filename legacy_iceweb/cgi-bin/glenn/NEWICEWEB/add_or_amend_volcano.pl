#!/usr/local/bin/perl

print "Content-type: text/html\n\n";

# Get the data submitted from volcano setup form
$form = <STDIN>;
print "$form<p>\n";

# Strip variables
($varname,$value)=split(/=/,$form);
if ($varname=="Volcano" {
	$volcano=$value;
}

# Make volcano setup form
write_volcano_setup_form($volcano);
