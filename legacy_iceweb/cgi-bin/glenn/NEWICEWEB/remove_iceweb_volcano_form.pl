#!/usr/bin/perl -w
use lib "$ENV{ANTELOPE}/data/perl";
use Datascope;
use lib "/home/glenn/NEWICEWEB";
use read_parameters qw(read_volcanoes);

@iceweb_volcanoes=&read_volcanoes;

# Print out top of html page
print "<HTML><HEAD>\n";
print "<TITLE> Select IceWeb Volcano </TITLE></HEAD>\n";
print "<BODY><FORM ACTION=\"http://www.avo.alaska.edu/cgi-bin/glenn/remove_iceweb_volcanoes.pl\" METHOD=\"POST\">\n";
print "<hr>\n";
print "<FONT SIZE=7> <center> Select IceWeb Volcano </center></FONT><P>\n";

# horizontal line separator
print "<hr>\n";

# display info	
print "<h1>Volcanoes currently monitored by IceWeb</H1><p>\n";
print "Deselect from the list below to remove volcanoes from IceWeb<p>\n";
for ($volcano_num=0;$volcano_num<=$#iceweb_volcanoes;$volcano_num++) {
	$volcano=$iceweb_volcanoes[$volcano_num];
	print "<INPUT TYPE=\"checkbox\" NAME=\"Volcano\" VALUE=\"$volcano\" CHECKED>$volcano<br>\n";
};

# horizontal line separator
print "<hr>\n";

# Submit & Reset Buttons
print "<INPUT TYPE=\"submit\" VALUE=\"Apply\"><INPUT TYPE=\"reset\" VALUE=\"Reset\"></FORM>\n";

# horizontal line separator
print "<hr>\n";

# Author information
print "<ADDRESS>Prototype by Glenn Thompson, 11th October 1999</ADDRESS>\n";

# End of html
print "</body></html>\n";







