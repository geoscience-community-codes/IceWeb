#! /usr/bin/perl

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);

print "$sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst\n";
