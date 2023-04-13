#!/usr/local/bin/perl -w
use cgi_utilities qw(write_volcanoes_parameter_file);
$PFS="/home/iceweb/PARAMETER_FILES";

print "Content-type: text/html\n\n";
print "<HTML><HEAD>\n";
print "<TITLE>Volcano Setup</TITLE></HEAD><BODY>\n";

# Get the data submitted from volcano setup form
$form = <STDIN>;

# Strip variables
$volcano_num=-1;
@pairs = split(/&/,$form); # split at ampersands, put subscripts into array 'pairs'
foreach $pair (@pairs) {
	($varname,$value)=split(/=/,$pair);
	if ($varname eq "Volcano") {
		$volcano_num++;
		$volcanoes[$volcano_num]=$value;
	}
};	

# Write volcanoes parameter file
if (volcano_num != -1) {
	&write_volcanoes_parameter_file(@volcanoes);
};
print "Back to <A HREF=\"/ICEWEB/SETUP/index.html\">main</A> menu</BODY></HTML>\n";

