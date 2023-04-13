#!/usr/bin/perl -w
# enviroment variables not inherited by cgi-scripts,
# so paths must be hard coded (which makes them more
# likely to break!)
#use lib "/opt/antelope/4.2u/data/perl";
use lib "/opt/antelope/4.8/data/perl";
use Datascope;
use lib "/home/iceweb/ICEWEB_UTILITIES";
use read_database qw(VolcanoNames);
use iceweb_perl_utilities qw(read_volcanoes);
print "Content-type: text/html\n\n";

# Get the data submitted from volcano setup form
$form = <STDIN>;
#$form = "choice=add";
($varname,$value) = split(/=/,$form);
if ($value eq "add") {
	&add_iceweb_volcano_form();
};
if ($value eq "change") {
	&amend_iceweb_volcano_form();
};
if ($value eq "remove") {
	&remove_iceweb_volcano_form();
};

sub add_iceweb_volcano_form {

	@iceworm_volcanoes=VolcanoNames;
	@iceweb_volcanoes=&read_volcanoes;

	# Print out top of html page
	print "<HTML><HEAD>\n";
	print "<TITLE> New IceWeb Volcano </TITLE></HEAD>\n";
	print "<BODY><FORM ACTION=\"http://www.avo.alaska.edu/cgi-bin/iceweb/add_or_amend_volcano.pl\" METHOD=\"POST\">\n";
	print "<hr>\n";
	print "<FONT SIZE=7> <center> New IceWeb Volcano </center></FONT><P>\n";

	# horizontal line separator
	print "<hr>\n";

	# display info	
	print "<h1>Iceworm volcanoes</H1><p>\n";
	print "Volcanoes currently on Iceworm are: <br>@iceworm_volcanoes <p>\n";

	print "<h1>IceWeb volcanoes</H1><p>\n";
	print "Volcanoes currently on IceWeb are: <br>@iceweb_volcanoes <p>\n";

	# horizontal line separator
	print "<hr>\n";

	print "<h1>Enter volcano to add (or Back to cancel): </h1><p>\n(Do not use spaces - use underscore instead)<br>";
	print "<INPUT TYPE=\"textbox\" NAME=\"Volcano\" SIZE=\"10\"><p>\n";
	
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
	print "<TITLE> Modify Volcano Setup </TITLE></HEAD>\n";
	print "<BODY><FORM ACTION=\"http://www.avo.alaska.edu/cgi-bin/iceweb/add_or_amend_volcano.pl\" METHOD=\"POST\">\n";
	print "<hr>\n";
	print "<FONT SIZE=7> <center> Modify Volcano Setup </center></FONT><P>\n";
	
	# horizontal line separator
	print "<hr>\n";
	
	# display info	
	print "<h1>Volcanoes currently monitored by IceWeb</H1><p>\n";
	print "Choose from the list below<p>\n";
	for ($volcano_num=0;$volcano_num<=$#iceweb_volcanoes;$volcano_num++) {
		$volcano=$iceweb_volcanoes[$volcano_num];
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


sub remove_iceweb_volcano_form {

	@iceweb_volcanoes=&read_volcanoes;

	# Print out top of html page
	print "<HTML><HEAD>\n";
	print "<TITLE> Select IceWeb Volcano </TITLE></HEAD>\n";
	print "<BODY><FORM ACTION=\"http://www.avo.alaska.edu/cgi-bin/iceweb/remove_iceweb_volcanoes.pl\" METHOD=\"POST\">\n";
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





