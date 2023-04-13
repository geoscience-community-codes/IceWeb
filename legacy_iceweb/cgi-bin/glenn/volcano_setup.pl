#!/usr/local/bin/perl

print "Content-type: text/html\n\n";

# Get the data submitted from volcano setup form
$form = <STDIN>;
#$form="station=SSLN&threshold=1.8&av=1&station=SSLW&threshold=0.5&station=SSLS&threshold=5.5&av=1&station=&threshold=+&station=&threshold=+&station=&threshold=+&windstation=cbwind";
print "$form<p>\n";

# Strip variables
$station_num=-1;
$plot_num=-1;
@pairs = split(/&/,$form); # split at ampersands, put subscripts into array 'pairs'
foreach $pair (@pairs) {
	($varname,$value)=split(/=/,$pair);
	if ($value ne "" && $value ne "+") { # either of "" or "+" would mean value undefined, so nothing to do
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

print "@stations $#stations<p>\n";
print "@thresholds<p>\n";
print "@flags<p>\n";
print "@drplots<p>\n";
print "$windstation<p>\n";

# CHECK THESE STATIONS EXIST ON ICEWORM

# CHECK THRESHOLD ARRAY IS VALID

# NOTHING ELSE NEEDS CHECKING - OUTPUT IS FIXED BY FORM

# SAVE NEW PARAMETER FILE - need to know volcano name - for now fix at 'Test'
if ($station_num != -1) {
	save_new_parameter_file("test4");
};

# RUN update_www_pages.pl
chmod("/home/glenn/NEWICEWEB");
update_www_pages.pl;

sub save_new_parameter_file {
	$volcano=$_[0];

	$PARAMETER_FILES="/home/glenn/NEWICEWEB/PARAMETER_FILES";
	$fname="$PARAMETER_FILES/$volcano";

	print "$fname.pf<p>\n";
	
	# BACKUP OLD PARAMETER FILE
	#system("mv $fname.pf $fname.pf.backup");

	# open new volcano parameter file
	open(OUT,">$fname.pf");
	if (defined(OUT)) {
		print "file opened\n";
		# write stations part
		print OUT "stations &Arr {\n";
		for ($station_num=0;$station_num<=$#stations;$station_num++) {
			print OUT "$stations[$station_num] &Arr{\n";
			print OUT "threshold $thresholds[$station_num]\n";
			print OUT "useinav $flags[$station_num]\n";
			print OUT "}\n";
		};
		print OUT "}\n";
		# write dr plots part
		print OUT "drplots &Tbl {\n";
		if ($plotnum != -1) { # there may not be any to write!
			for ($plotnum=0;$plotnum<=$#drplots;$plotnum++) {
				print OUT "$drplots[$plotnum]\n";
			};
		};
		print OUT "}\n";
		
		# write spectrogram flag  - this isn't on form yet!
		# print OUT "spectrograms $spectrogram_flag\n"; # either 'y' or 'n'
	
		# write windstation
		print OUT "windstation $windstation\n";
	
		# close file
		close(OUT);
		
	} 
	else 
	{
		print "file could not be opened\n";
	};
};

		
