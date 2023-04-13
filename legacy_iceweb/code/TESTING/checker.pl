#!/usr/bin/perl -w
# Glenn Thompson, September 1999
# This script checks when iceweb.pl last ran successfully
# ideally it should run from a completely different machine
# than iceweb.pl
# if iceweb.pl last ran more than 0.1 days ago, warnings are sent

# Setup paths & modules
$ICEWEB=$ENV{HOME}; # iceweb home
$PFS=$ENV{PFS}; # parameter files

use lib "$ENV{ANTELOPE}/data/perl"; # antelope-perl interface
use Datascope; # Datascope.pm module


if ((-M "$ICEWEB/TESTING/last_ran") > 0.1) {
	$error_string = "IceWeb has not run successfully for at least 2.4 hours";
	$IceWeb_manager=pfget("$PFS/parameters.pf","IceWeb_manager");
	system("echo $error_string | mailx $IceWeb_manager");
};
