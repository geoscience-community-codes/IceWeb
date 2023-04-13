#!/usr/bin/perl -w
use lib "$ENV{ANTELOPE}/data/perl";
use Datascope;
use lib "/home/iceweb/ICEWORM_UTILITIES";
use read_database qw(VolcanoNames);
use lib "/home/iceweb/ICEWEB_UTILITIES";
use read_parameters qw(read_volcanoes);

print "Content-type: text/html\n\n";

# Get the data submitted from volcano setup form
$form = <STDIN>;
($varname,$value) = split(/=/,$form);
if ($value eq "add") {
	add_iceweb_volcano_form;
};
if ($value eq "change") {
	amend_iceweb_volcano_form;
};
if ($value eq "remove") {
	remove_iceweb_volcano_form;
};

sub add_iceweb_volcano {

	@iceworm_volcanoes=VolcanoNames;

	# Print out top of html page
	print "<HTML><HEAD>\n";
	print "<TITLE> Select Iceworm Volcano </TITLE></HEAD>\n";
	print "<BODY><FORM ACTION=\"http://www.avo.alaska.edu/cgi-bin/glenn/add_or_amend_volcano.pl\" METHOD=\"POST\">\n";
	print "<hr>\n";
	print "<FONT SIZE=7> <center> Select Iceworm Volcano </center></FONT><P>\n";

	# horizontal line separator
	print "<hr>\n";

	# display info	
	print "<h1>Iceworm volcanoes</H1><p>\n";
	print "To add a volcano to IceWeb, it must be on Iceworm. Choose from the following list<br>. If you choose a volcano that has been on IceWeb before, the last setup for that volcano will be displayed.<p>\n";
	for ($volcano_num=0;$volcano_num<=$#iceworm_volcanoes;$volcano_num++) {
		$volcano=$iceworm_volcanoes[$volcano_num];
		print "<INPUT TYPE=\"radio\" NAME=\"Volcano\" VALUE=\"$volcano\">$volcano<br>\n";
	};
	
	# horizontal line separator
	print "<hr>\n";
	
	# Submit & Reset Buttons
	print "<INPUT TYPE=\"submit\" VALUE=\"Submit\"><INPUT TYPE=\"reset\" VALUE=\"Reset\"></FORM>\n";
	
	# horizontal line separator
	print "<hr>\n";
	
	# Author information
	print "<ADDRESS>Prototype by Glenn Thompson, 11th October 1999</ADDRESS>\n";
	
	# End of html
	print "</body></html>\n";
	
};


sub amend_iceweb_volcano_form {

	@iceweb_volcanoes=&read_volcanoes;

	# Print out top of html page
	print "<HTML><HEAD>\n";
	print "<TITLE> Select IceWeb Volcano </TITLE></HEAD>\n";
	print "<BODY><FORM ACTION=\"http://www.avo.alaska.edu/cgi-bin/glenn/add_or_amend_volcano.pl\" METHOD=\"POST\">\n";
	print "<hr>\n";
	print "<FONT SIZE=7> <center> Select IceWeb Volcano </center></FONT><P>\n";
	
	# horizontal line separator
	print "<hr>\n";
	
	# display info	
	print "<h1>Volcanoes currently monitored by IceWeb</H1><p>\n";
	print "Choose from the list below<p>\n";
	for ($volcano_num=0;$volcano_num<=$#iceworm_volcanoes;$volcano_num++) {
		$volcano=$iceworm_volcanoes[$volcano_num];
		print "<INPUT TYPE=\"radio\" NAME=\"Volcano\" VALUE=\"$volcano\">$volcano<br>\n";
	};
	
	# horizontal line separator
	print "<hr>\n";
	
	# Submit & Reset Buttons
	print "<INPUT TYPE=\"submit\" VALUE=\"Submit\"><INPUT TYPE=\"reset\" VALUE=\"Reset\"></FORM>\n";
	
	# horizontal line separator
	print "<hr>\n";
	
	# Author information
	print "<ADDRESS>Proto	type by Glenn Thompson, 11th October 1999</ADDRESS>\n";
	
	# End of html
	print "</body></html>\n";

};


sub remove_iceweb_volcano_form {

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
};





