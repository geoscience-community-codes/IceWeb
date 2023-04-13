#!/usr/bin/perl -w

# Perl script to kill leftover jobs like alchemy and ftp.  This is an ugly cludge, but until
# we upgrade iceweb code to task driven processes, we'll have to live with this.
# This script should be run by a cron job every few minutes or so.
# Guy Tytgat, 22 March 2000
# Guy Tytgat, 02 Dec 2004: added checking for when the spectrograms gets stuck as well
# Mike West, 09 Feb 2005: changed matlab job search to include different matlab paths. Small change in log format
# Guy Tytgat, 11 Feb 2005: changed matlab job search to return the command name, not all the arguments.  Also added "grep iceweb" in the search for ftpjobs


# Get the lists of jobs that are running currently for the alchemy, ftp and spectrograms...
@alchemyjobs = `ps -ef -o user,pid,stime,args | grep alchemy | grep -v grep`;
@ftpjobs = `ps -ef -o user,pid,stime,args | grep ftp | grep iceweb | grep -v grep`;
# @matlabjobs = `ps -ef -o user,pid,stime,args | grep /usr/local/bin/matlab | grep -v grep`;
# @matlabjobs = `ps -ef -o user,pid,stime,args | grep iceweb | grep matlab | grep -v grep`;
@matlabjobs = `ps -ef -o user,pid,stime,comm | grep iceweb | grep matlab | grep -v grep`;

# Get the current time in number of seconds since the start of the day...
$nowtime = `epoch -o US/Alaska +%H:%M:%S now`;
$nt = `epoch +%E $nowtime`;
print $nowtime;


# Set the maximum time allowed to run for each process (in seconds)...
$MaxAlchemyTime = 120;
$MaxFtpTime = 600;
$MaxMatlabTime = 540;

print "Checking alchemy jobs...\n";
foreach $aj (@alchemyjobs) {
  print "$aj";
  $starttime = substr($aj,15,8);
  print "$starttime\n";
  $st = `epoch +%E $starttime`;
  $jobnumber = substr($aj,9,5);

  $dt = $nt - $st;
  print "dt = $dt\n";

  if ($dt > $MaxAlchemyTime) {
    print "Process $jobnumber killed\n";
    kill 9, $jobnumber;
  }
}

print "Checking ftp jobs...\n";
foreach $fj (@ftpjobs) {
  print "$fj";
  $starttime = substr($fj,15,8);
  print "$starttime\n";
  $st = `epoch +%E $starttime`;
  $jobnumber = substr($fj,9,5);

  $dt = $nt - $st;
  print "dt = $dt\n";

  if ($dt > $MaxFtpTime) {
    kill 9, $jobnumber;
    print "Process $jobnumber killed\n";
  }
}

print "Checking Matlab jobs...\n";
foreach $mj (@matlabjobs) {
  print "$mj";
  $starttime = substr($mj,15,8);
  print "        start time: $starttime    ";
  $st = `epoch +%E $starttime`;
  $jobnumber = substr($mj,9,5);

  $dt = $nt - $st;
  print "dt = $dt\n";

  if ($dt > $MaxMatlabTime) {
    kill 9, $jobnumber;
    print "        Process $jobnumber killed\n";
  }
}

print "done...\n\n\n";
