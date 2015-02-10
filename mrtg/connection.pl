#!/usr/bin/perl
# Get connection# for MRTG
# 16:24 2008/7/21
# Jonathan Tsai

$chkport=!defined($ARGV[0])?"80":$ARGV[0];
$mrtgline1 = `netstat -n | grep ":$chkport "|awk '{print \$5}'|sort | wc -l|awk '{print\$1 - 1}'`;
$mrtgline2=`netstat -n | grep ":$chkport "|awk '{print \$5}'|cut -d":" -f1|sort| uniq |wc -l | awk '{print \$1 - 1}'`;
$UPtime=`/usr/bin/uptime | awk '{print \$3 " " \$4 " " \$5}'`;
$hostname=`/bin/hostname`;
print($mrtgline1);
print($mrtgline2);
print($UPtime);
print($hostname);
