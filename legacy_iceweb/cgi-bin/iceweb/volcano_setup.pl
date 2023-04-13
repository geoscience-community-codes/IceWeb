#!/usr/local/bin/perl
# enviroment variables not inherited by cgi-scripts,
# so paths must be hard coded (which makes them more
# likely to break!)
#use lib "/opt/antelope/4.2u/data/perl";
use lib "/opt/antelope/4.8/data/perl";
use Datascope;
use lib "/home/iceweb/ICEWEB_UTILITIES";
use iceweb_perl_utilities qw(read_volcanoes);
use cgi_utilities qw(write_volcanoes_parameter_file);
use FileHandle;
$PFS="/home/iceweb/PARAMETER_FILES";

print "Content-type: text/html\n\n";
print "<HTML><HEAD>\n";
print "<TITLE>Volcano Setup</TITLE></HEAD><BODY>\n";


# Get the data submitted from volcano setup form
$form = <STDIN>;
#$form="Volcano=STHELENS&station=SSLN&threshold=1.8&av=1&station=SSLW&threshold=0.5&station=SSLS&threshold=5.5&av=1&station=&threshold=+&station=&threshold=+&station=&threshold=+&windstation=cbwind";


# Strip variables
$station_num=-1;
$plot_num=-1;
@pairs = split(/&/,$form); # split at ampersands, put subscripts into array 'pairs'
foreach $pair (@pairs) {
	($varname,$value)=split(/=/,$pair);
	if ($value ne "" && $value ne "+") { # either of "" or "+" would mean value undefined, so nothing to do
		if ($varname eq "Volcano") {
			$volcano=$value;
		};
		if ($varname eq "station") {
			$station_num++;
			$stations[$station_num]=$value;
			$thresholds[$station_num]=0;
			$flags[$station_num]=0;
		};
		if ($varname eq "threshold" && $value ne "") {
			$thresholds[$station_num]=$value;
		};
		if ($varname eq "av") {
			$flags[$station_num]=1;
		};
		if ($varname eq "drplots") {
			$plotnum++;
			$drplots[$plotnum]=$value;
		};
		if ($varname eq "windstation") {		
			$windstation=$value;
		};
	};
};	

# CHECK THESE STATIONS EXIST ON ICEWORM - AND DISTANCE & RESPONSE DATA EXIST

# CHECK THRESHOLD ARRAY IS VALID

# SAVE NEW PARAMETER FILE - need to know volcano name
if ($station_num != -1) {
	save_new_parameter_file($volcano);
};

# UPDATE VOLCANOES.PF IF NECESSARY
$TRUE=1;
$FALSE=0;
$FOUND=$FALSE;
@volcanoes=&read_volcanoes;
$volcano_num=0;
while ($volcano_num <= $#volcanoes && $FOUND==$FALSE) {
	if ($volcanoes[$volcano_num] eq $volcano) {
		$FOUND=$TRUE;
	} 
	else
	{
	$volcano_num++;
	}
};

if ($FOUND==$FALSE) {
	@volcanoes[$#volcanoes+1]=$volcano;
	write_volcanoes_parameter_file(@volcanoes);
};
print "Back to <A HREF=\"/ICEWEB/SETUP/index.html\">main</A> menu</BODY></HTML>\n";


#############################################################################################

sub save_new_parameter_file {
	$volcano=$_[0];

	$fname="$PFS/$volcano";
	
	# BACKUP OLD PARAMETER FILE
	system("mv $fname.pf $fname.pf.backup");

	# open new volcano parameter file
	$fh=new FileHandle ">$fname.pf";

	if (defined($fh)) { # output file exists

		# write stations part
		print $fh "stations &Arr{\n";
		for ($station_num=0;$station_num<=$#stations;$station_num++) {
			print $fh "$stations[$station_num] &Arr{\n";
			print $fh "threshold \t$thresholds[$station_num]\n";
			print $fh "use \t\t$flags[$station_num]\n";
			print $fh "}\n";
		};
		print $fh "}\n";

		# write windstation
		print $fh "windstation \t$windstation\n";
	
		# write dr plots part
		print $fh "dr_plots &Tbl{";
		if ($plotnum != -1) { # there may not be any to write!
			for ($plotnum=0;$plotnum<=$#drplots;$plotnum++) {
				print $fh "$drplots[$plotnum]\n";
			};
		};
		print $fh "}\n";
		
		# close file
		close($fh);
		print "Parameter file $fname.pf has been saved<p>\n";
		
	} 
	else 
	{
		print "sorry - you do not have permission to save $fname.pf<p>\n";
	};
	return 1;
};

		
