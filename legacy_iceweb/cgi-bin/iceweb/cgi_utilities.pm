# Glenn Thompson, October 1999
package cgi_utilities;
require Exporter;
@ISA=qw(Exporter);
@EXPORT=qw(write_volcanoes_parameter_file);
$PFS="/home/iceweb/PARAMETER_FILES";
use FileHandle;

sub write_volcanoes_parameter_file {

	@volcanoes=@_;

	$fname="$PFS/volcanoes";

	# BACKUP OLD PARAMETER FILE
	system("mv $fname.pf $fname.pf.backup");

	# open new volcano parameter file
	$fh=new FileHandle ">$fname.pf";

	if (defined($fh)) {

		# write stations part
		print $fh "volcanoes &Tbl{\n";
		for ($volcano_num=0;$volcano_num<=$#volcanoes;$volcano_num++) {
			print $fh "$volcanoes[$volcano_num]\n";
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
};
