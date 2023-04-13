#!/usr/bin/tcsh
# Glenn Thompson 1999 -> Celso Reyes 2003
# This script calls a C program that starts Matlab
# and runs $ICEWEB/counts.m
# That function updates the counts displayed on the
# AVO internal page
# This script is executed once per day
cd /home/iceweb/COUNTS
/home/iceweb/ICEWEB_UTILITIES/start_matlab_engine4.6 update_counts_plots

