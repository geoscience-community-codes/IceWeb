#!/usr/local/bin/perl

print "Content-type: text/html\n\n";

# Get the data submitted from volcano setup form
$form = <STDIN>;
print "$form<p>\n";

# Strip variables
$volcano_num=-1;
@pairs = split(/&/,$form); # split at ampersands, put subscripts into array 'pairs'
foreach $pair (@pairs) {
	($varname,$value)=split(/=/,$pair);
	if ($varname=="Volcano" {
		$volcano_num++;
		$volcanoes[$volcano_num]=$value;
	}
};	

print "@volcanoes $#volcanoes<p>\n";

# Write volcanoes parameter file
if volcano_num != -1) {
	write_volcanoes_parameter_file;
};

# RUN update_www_pages.pl
chmod("/home/glenn/NEWICEWEB");
update_www_pages.pl;

sub write_volcanoes_parameter_file {

	$PARAMETER_FILES="/home/glenn/NEWICEWEB/PARAMETER_FILES";
	$fname="$PARAMETER_FILES/volcanoes";

	print "$fname.pf<p>\n";
	
	# BACKUP OLD PARAMETER FILE
	system("mv $fname.pf $fname.pf.backup");

	# open new volcano parameter file
	open(OUT,">$fname.pf");
	if (defined(OUT)) {
		print "file opened\n";
		# write stations part
		print OUT "volcanoes &Tbl {\n";
		for ($volcano_num=0;$volcano_num<=$#volcanoes;$volcano_num++) {
			print OUT "$volcanoes[$volcano_num]\n";
		};
		print OUT "}\n";
		# close file
		close(OUT);		
	} 
	else 
	{
		print "file could not be opened\n";
	};
};

		
