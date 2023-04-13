#!/usr/bin/perl -w

#use lib "/opt/antelope/4.3u/data/perl";
use lib "/opt/antelope/4.8/data/perl";
use Datascope;

$nowe = now;
                                                
$nows = epoch2str($nowe,"%Y-%m-%d %H:%M:%S",'US/Alaska');

print "$nows\n\n";
