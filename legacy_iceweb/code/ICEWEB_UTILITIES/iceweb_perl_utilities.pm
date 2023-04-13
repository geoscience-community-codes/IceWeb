package iceweb_perl_utilities;
# environment variables are not inherited by cgi scripts,
# so unfortunately have to replace environment variables
# with hard coded paths! the downside is these need manually
# upgrading whenever Antelope is upgraded/moved

use lib "$ENV{ANTELOPE}/data/perl";
#use lib "/opt/antelope/4.3u/data/perl";
use Datascope;
require Exporter;
@ISA=qw(Exporter);
@EXPORT=qw(send_IceWeb_error read_volcanoes read_stations read_thresholds read_use read_windstation read_drplots read_allowed_drplots get_time date2dnum update_web_pages);
@EXPORT_OK=qw(@volcanoes @stations @thresholds @use $windstation @dr_plots $year $mon $mday $hour $min $dnum);

#$PFS="$ENV{PFS}";
#$ICEWEB="$ENV{HOME}";
$ICEWEB="/home/iceweb";
$PFS="$ICEWEB/PARAMETER_FILES";

##############################################################################################

# for emailing any errors that occur in IceWeb

sub send_IceWeb_error {
	$error_string = $_[0];
	$errorfile="/tmp/errormsg";
	$IceWeb_manager=pfget("$PFS/parameters.pf","IceWeb_manager");
	print "ERROR: $error_string\n";
	open(ERR,">$errorfile") || die "send_IceWeb_error: cannot write error file $errorfile\n";
	print ERR "$error_string\n";
	close(ERR);
	system("mailx $IceWeb_manager < $errorfile");
	unlink($errorfile);
	return 1;
};

##############################################################################################

# for reading IceWeb setup data from parameter files

sub read_volcanoes {
	my $pf="$PFS/volcanoes.pf";
	$volcanoesref=pfget($pf,"volcanoes");
	@volcanoes=@$volcanoesref;
	return @volcanoes;
}

sub read_stations {
	$volcano = $_[0];
	my $pf="$PFS/$volcano.pf";
	$stationsref=pfget($pf,"stations");
	@stations=keys %$stationsref;
	return @stations;
}

sub read_thresholds {
	($volcano,@stations) = @_;
	my $pf="$PFS/$volcano.pf";
	for ($station_num=0;$station_num<=$#stations;$station_num++) {
		$station=$stations[$station_num];
		$thresholds[$station_num]=pfget($pf,"stations \{$station \{threshold\} \} ");
	};
	return @thresholds;		
}

sub read_use {
	($volcano,@stations) = @_;
	my $pf="$PFS/$volcano.pf";
	for ($station_num=0;$station_num<=$#stations;$station_num++) {
		$station=$stations[$station_num];
		$use[$station_num]=pfget($pf,"stations \{$station \{use\} ");
	};
	return @use;		
}

sub read_windstation {
	$volcano = $_[0];
	my $pf="$PFS/$volcano.pf";
	$windstation=pfget($pf,"windstation");
	return $windstation;
}	

sub read_drplots {
	$volcano = $_[0];
	my $pf="$PFS/$volcano.pf";
	$drplotsref=pfget($pf,"dr_plots");
	@drplots=@$drplotsref;
	return @drplots;
}

sub read_allowed_drplots {
	my $pf="$PFS/parameters.pf";
	$allowed_drplots_ref=pfget($pf,"allowed_dr_plots");
	@allowed_drplots=@$allowed_drplots_ref;
	return @allowed_drplots;
};

##############################################################################################

# to get local (Alaskan) or UT time in Y2K compatible form

sub get_time {
	($zone,$days_ago)=@_;
	$secs_per_day=60*60*24;

	# use Perl time functions - would be good to replace these Perl routines with epoch2str
	if ($zone eq "local") {
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time-$days_ago*$secs_per_day);
	}
	elsif ($zone eq "ut") {
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime(time-$days_ago*$secs_per_day);
	}
	else
	{
		die("get_time: zone must be 'local' or 'ut'\n");
	};

	# month returned by time has 0 for Jan, 1 for Feb,... make it 1 for Jan, 2 for Feb, ...
	$mon=$mon+1;

	# Hack required since perl function 'localtime' returns only 2 digit year
	# modified by Mitch Robinson 1-31-2000
# print "YEAR = $year\n";
	if ($year < 1000 ) {
	  $year = $year + 1900;
	}
#	Temporary hack to fix the date problem...
#	$year = $year + 2000;

	# make sure month, day, hour & minute are all 2 digit strings
	if (length($mon)==1) { $mon = "0" . "$mon"; };
	if (length($mday)==1) { $mday = "0" . "$mday"; };
	if (length($hour)==1) { $hour = "0" . "$hour"; };
	if (length($min)==1) { $min = "0" . "$min"; };

	# return results
	return ($year,$mon,$mday,$hour,$min);
};


sub date2dnum {
	($year,$mon,$day,$hour,$min)=@_;
	@dayspermonth = (0,31,28,31,30,31,30,31,31,30,31,30,31);
	$m=0;
#	$yday=$day-1;
	$yday=$day;
	while ($mon>$m) {
		$yday=$yday+$dayspermonth[$m];
		$m++;
	};
	$Jan_01_1998=729756;
	$dnum=$Jan_01_1998+$yday+($year-1998)*365+$hour/24+$min/(24*60);
	$dnum = substr($dnum,0,10);
	return $dnum;
};

##############################################################################################

# to update web pages whenever IceWeb stations/volcanoes have been altered

sub update_web_pages {

	# Glenn Thompson, September 1999
	# This perl script should be run after every change to parameter file -
	# it updates dr and spectrogram html pages on the AVO internal page

	# Read http paths from parameter file
	$INTERNAL=pfget("$PFS/paths.pf","INTERNAL");
	$internalpath=pfget("$PFS/paths.pf","INTERNAL_HTTP");
	$drpath=pfget("$PFS/paths.pf","DR_HTTP");
	$specpath=pfget("$PFS/paths.pf","SPEC_HTTP");
	$countspath=pfget("$PFS/paths.pf","COUNTS_HTTP");
	$online_docs=pfget("$PFS/paths.pf","ONLINE_DOCS");

	# Other paths
	$DR_GIFS=pfget("$PFS/paths.pf","DR_GIFS");

	# short cut to menus
	$specmenu="$internalpath/seismenu_spec.html";
	$drmenu="$internalpath/seismenu_dr.html";
	$countsmenu="$internalpath/seismenu_counts.html";
	
	$num_mins=pfget("$PFS/parameters.pf","minutes_to_get");
	
	# Read list of volcanoes
	@volcanoes=&read_volcanoes();
	
	for ($volcano_num=0;$volcano_num<=$#volcanoes;$volcano_num++) {
		$volcano=$volcanoes[$volcano_num];
		@drplots=&read_drplots($volcano);
		foreach $days (@drplots) {
			&produce_dr_html($days,$volcano);
		};
	};
	
	&produce_seismenu_spec_html(@volcanoes);
	&produce_seismenu_dr_html(@volcanoes);
};

sub produce_dr_html {
	($days,$volcano)=@_;
	print("Producing last $days day dr html\n");
	@colors=("#3333FF","#FF0000","#33CC00","#CC33CC","#66FFFF","#FFFF10");
	print "@colors\n";
	$html_name = "$volcano" . "_$days.html";
	open(OUT,">$DR_GIFS/$html_name");
	print OUT "<html><head><title>$volcano Volcano Near-Real-Time Reduced Displacement Plots</title>\n";
	print OUT "<META HTTP-EQUIV=\"Refresh\" CONTENT=600; URL=\"$html_name\">\n";
	print OUT "</head>\n";
	print OUT "<body bgcolor = \"#FFFFFF\">\n";
	print OUT "<font size=4><strong><center>Near-Real Time Reduced Displacement 
Plots - Last $days days</strong></font><p>\n";
	$giffile="dr" . "$days" . "_$volcano" . ".gif";
	print OUT "<img src=\"$giffile\">\n";
#	@stations=&read_stations($volcano);
#	for ($station_num=0; $station_num<=$#stations; $station_num++) {
#		$station=$stations[$station_num];
#		$color=$colors[$station_num];
#		print OUT "<br><font color=\"$color\">....     Dr at $station</font>\n";
#	};
	# make fluff for dr plots
	$fluff = "<p>Each point is the maximum Dr in a $num_mins minute window.<br>This plot is computed by <A HREF=\"http://giseis.alaska.edu/internal/ICEWEB/ONLINE_DOCUMENTATION/IceWeb.html\">IceWeb</A> using near-real-time data from the <A HREF=\"http://giseis.alaska.edu/Input/kent/Iceworm.html\">Iceworm system</A> at the University of Alaska <A HREF=\"http://www.gi.alaska.edu/\">Geophysical Institute</A>.<p><center><A HREF=\"$online_docs/dr.html\">More about reduced displacment</A></center><p>\n";
	print OUT "$fluff<br></body></html>\n";
	close(OUT);
}; 

sub produce_seismenu_spec_html {
	@volcanoes=@_;
	print("Producing seismenu_spec.html\n");
print "INTERNAL = $INTERNAL\n";
print "specpath = $specpath\n";
	open(OUT,">$INTERNAL/seismenu_spec.html");
	print OUT "<HTML><HEAD><TITLE>AVO Menu</TITLE></HEAD>\n";
	print OUT "<BODY BGCOLOR=\"#000000\" TEXT=\"#FFFFFF\" LINK=\"#00FFFF\" VLINK=\"#00FF00\" ALINK=\"#FF0000\">\n";
	print OUT "<TABLE BORDER=0 CELLPADDING=0>\n";
	print OUT "<P><I><B><FONT size=+1 COLOR=\"#CC0000\">Volcano Seismology</FONT></B></I><HR>\n";
	print OUT "<I><a href=\"/internal/seismenu_guy.html\" target=\"specmenu\">Seismicity </I><BR></a><FONT SIZE=\"-1\">(Guy's short-term plots)</font><P>\n";
	print OUT "<I><a href=\"/internal/seismenu_seth.html\" target=\"avomain\">Seismicity </I><BR></a><FONT SIZE=\"-1\">(Seth's long-term plots)</font><P>\n";
	print OUT "<I><a href=\"/internal/seismenu_rsam.html\" target=\"specmenu\">RSAM</I><BR></a>\n";
	print OUT "<FONT SIZE= \"-1\"></font><P>\n";
	print OUT "<I><a href= \"$specmenu \" target=\"specmenu\"><FONT COLOR=\"#FFFF00\">Spectrograms</FONT></I><BR></a>\n";
	print OUT "<FONT SIZE=\"-1\">\n";
	for ($volcano_num=0;$volcano_num<=$#volcanoes;$volcano_num++) {
		$volcano=$volcanoes[$volcano_num];
		print OUT "$volcano<BR>\n";
		print OUT "<a href=\"$specpath/$volcano/l10m.html\" target=\"avo\"> 10m</a>\n";
		print OUT "<a href=\"$specpath/$volcano/l2h.html\" target=\"avo\"> 2hr</a>\n";
		print OUT "<a href=\"$specpath/$volcano/currentday.gif\" target=\"avo\"> today</a><BR>\n";
		print OUT "<a href=\"$specpath/$volcano/lastday.gif\" target=\"avo\"> yesterday</a><BR>\n";
	};
	print OUT "</FONT>\n";
	print OUT "<p><a href=\"$specpath/archive.html\" target=\"avo\"> archive</A>\n";
	# link to /spec/archive/archive.html has been removed - archive needs updating
	print OUT "<p><a href=\"$specpath/MosaicMaker.html\" target=\"avo\"> mosaics</A>\n";
	print OUT "<P><font size=-2>Problems? Mail <a href=\"mailto:guy\@giseis.alaska.edu\">Guy Tytgat</a><font><P>\n";
	print OUT "<I><a href=\"$drmenu \" target=\"specmenu\">Reduced Displacement</I><BR></a>\n";
	print OUT "<I><p><a href= \"$countsmenu \" target=\"specmenu\">Counts</I><BR></a>\n";
	print OUT "<P></BODY></HTML>\n";
	close(OUT);
};

sub produce_seismenu_dr_html {
	@volcanoes=@_;
	print("Producing seismenu_dr.html\n");
print "INTERNAL = $INTERNAL \n";	
	open(OUT,">$INTERNAL/seismenu_dr.html");
	print OUT "<HTML><HEAD><TITLE>AVO Menu</TITLE></HEAD>\n";
	print OUT "<BODY BGCOLOR=\"#000000\" TEXT=\"#FFFFFF\" LINK=\"#00FFFF\" VLINK=\"#00FF00\" ALINK=\"#FF0000\">\n";
	print OUT "<TABLE BORDER=0 CELLPADDING=0>\n";
	print OUT "<P><I><B><FONT size=+1 COLOR=\"#CC0000\">Volcano Seismology</FONT></B></I><HR>\n";
	print OUT "<I><a href=\"/internal/seismenu_guy.html\" target=\"specmenu\">Seismicity </I><BR></a><FONT SIZE=\"-1\">(Guy's short-term plots)</font><P>\n";
	print OUT "<I><a href=\"/internal/seismenu_seth.html\" target=\"avomain\">Seismicity </I><BR></a><FONT SIZE=\"-1\">(Seth's long-term plots)</font><P>\n";
	print OUT "<I><a href=\"/internal/seismenu_rsam.html\" target=\"specmenu\">RSAM</I><BR></a>\n";
	print OUT "<FONT SIZE= \"-1\"></font><P>\n";
print "specmenu = $specmenu\n";
print "drmenu = $drmenu\n";
	print OUT "<I><a href= \"$specmenu \" target=\"specmenu\">Spectrograms</I><P></a>\n";
	print OUT "<I><a href=\"$drmenu \" target=\"specmenu\"><FONT COLOR=\"#FFFF00\">Reduced Displacement</font></I><BR></a>\n";
	for ($volcano_num=0;$volcano_num<=$#volcanoes;$volcano_num++) {
		$volcano=$volcanoes[$volcano_num];
		@drplots=&read_drplots($volcano);
		if ($#drplots < 0) {
			print "no drplots for $volcano\n";
		} else {
			print "drplots @drplots for $volcano\n";	
			print OUT "$volcano<br>\n";
			foreach $days (@drplots) {
				print OUT "<A HREF=\"$drpath/$volcano" . "_$days.html\" target=\"avo\"> last $days days</A><br>\n";
			};
			print OUT "<br>\n";
		};
	}
	print OUT "<P>\n";			
	print OUT "<font size=-2>Problems? Mail <a href=\"mailto:guy\@giseis.alaska.edu\">Guy Tytgat</a><font>\n";
	print OUT "<I><p><a href= \"$countsmenu \" target=\"specmenu\">Counts</I><BR></a>\n";
	print OUT "<P></BODY></HTML>\n";
	close(OUT);	
};
