#!/usr/bin/perl -w
# Glenn Thompson, September 1999
# This is the main script controlling iceweb

#use lib "$ENV{ANTELOPE}/data/perl"; # antelope-perl interface
#use Datascope; # Datascope.pm module

use lib "$ENV{HOME}/ICEWEB_UTILITIES"; # utilities for talking to iceweb parameter files
use iceweb_perl_utilities qw(update_web_pages);

&update_web_pages;
