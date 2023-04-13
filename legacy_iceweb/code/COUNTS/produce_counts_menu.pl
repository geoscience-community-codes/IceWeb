#!/usr/bin/perl
# Setup stuff
use lib "$ENV{ANTELOPE}/data/perl";
use Datascope;

&produce_counts_menu_html();


sub produce_counts_menu_html() {
	print("Producing seismenu_counts\n");
	$INTERNAL=pfget("iceweb.pf","INTERNAL");
	open(OUT,">$INTERNAL/seismenu_counts.html");
	print OUT "<HTML><HEAD><TITLE>AVO Menu</TITLE></HEAD>\n";
	print OUT "<BODY BGCOLOR=\"#000000\" TEXT=\"#FFFFFF\" LINK=\"#00FFFF\" VLINK=\"#00FF00\" ALINK=\"#FF0000\">\n";
	print OUT "<TABLE BORDER=0 CELLPADDING=0>\n";
	print OUT "<P><I><B><FONT size=+1 COLOR=\"#CC0000\">Volcano Seismology</FONT></B></I><HR>\n";
	print OUT "<I><a href=\"/internal/seismenu_guy.html\" target=\"specmenu\">Seismicity </I><BR></a><FONT SIZE=\"-1\">(Guy's short-term plots)</font><P>\n";
	print OUT "<I><a href=\"/internal/seismenu_seth.html\" target=\"specmenu\">Seismicity </I><BR></a><FONT SIZE=\"-1\">(Seth's long-term plots)</font><P>\n";
	print OUT "<I><a href=\"/internal/seismenu_rsam.html\" target=\"specmenu\">RSAM</I><BR></a>\n";
	print OUT "<FONT SIZE= \"-1\"></font><P>\n";
	print OUT "<I><a href= \"$specmenu \" target=\"specmenu\">Spectrograms</I><P></a>\n";
	print OUT "<I><a href=\"$drmenu \" target=\"specmenu\">Reduced Displacement<p></I></a>\n";
	print OUT "<I><a href= \"$countsmenu \" target=\"specmenu\"><FONT COLOR=\"#FFFF00\">Counts</FONT></I><BR></a>\n";
	print OUT "<FONT SIZE=\"-1\"><p>\n";
	# following should be turned into a control file
	$COUNTS=pfget("iceweb.pf","COUNTS");	
	open(IN,"<$COUNTS/volcanoes.ext");
	while (read(IN, $volname,10)) {
		$volname=~ s/ //g;
		if (length($volname)>4) {
			print OUT "<a href=\"$countspath/$volname.gif\" target=\"avo\"> $volname<br></a>\n";
		read(IN, $filler,1);
		};
	};
	close(IN);
	print OUT "</FONT>\n";
	print OUT "</FONT><P><font size=-2>Problems? Mail <a href=\"mailto:glenn\@giseis.alaska.edu\">Glenn Thompson<BR></a><font><P>\n";
	print OUT "<P></BODY></HTML>\n";
	close(OUT);
};
