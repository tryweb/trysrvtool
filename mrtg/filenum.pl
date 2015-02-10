#!/usr/bin/perl
# Get dir file# for MRTG
# 22:09 2014/4/14
# Jonathan Tsai

$chkdir1=!defined($ARGV[0])?'/var/spool/mqueue':$ARGV[0];
$chkdir2=!defined($ARGV[1])?'/var/spool/mqueue.in':$ARGV[1];

$mrtgline1 = `ls "$chkdir1" | wc -l`;
$mrtgline2 = `ls "$chkdir2" | wc -l`;
$UPtime=`/usr/bin/uptime | awk '{print \$3 " " \$4 " " \$5}'`;
$hostname=`/bin/hostname`;
print($mrtgline1);
print($mrtgline2);
print($UPtime);
print($hostname);
