#!/usr/bin/perl
# 16:51 2008/7/21
# Jonathan Tsai

$mrtgline1=`/usr/bin/sar -u 1 3 | grep Average | awk '{print \$3}'`;
$mrtgline1=round($mrtgline1)."\n";
$mrtgline2=`/usr/bin/sar -u 1 3 | grep Average | awk '{print \$5}'`;
$mrtgline2=round($mrtgline2)."\n";
$UPtime=`/usr/bin/uptime | awk '{print \$3 " " \$4 " " \$5}'`;
$hostname=`/bin/hostname`;
print($mrtgline1);
print($mrtgline2);
print($UPtime);
print($hostname);

sub round {
    my($number) = @_;
    return int($number + .5);
}

