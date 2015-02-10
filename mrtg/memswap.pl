#!/usr/bin/perl
# 23:33 2013/05/31
# Jonathan Tsai

$mrtgline1a=`cat /proc/meminfo | grep SwapTotal | awk '{print \$2}'`;
$mrtgline1b=`cat /proc/meminfo | grep SwapFree | awk '{print \$2}'`;
$mrtgline1=round($mrtgline1a - $mrtgline1b)."\n";
$mrtgline2=`cat /proc/meminfo | grep MemFree | awk '{print \$2}'`;
$mrtgline2=round($mrtgline2)."\n";
$UPtime=`/usr/bin/uptime | awk '{print \$3 " " \$4 " " \$5}'`;
$hostname=`/bin/hostname`;
print($mrtgline1);
print($mrtgline2);
print($UPtime);
print($hostname);

sub round {
    my($number) = @_;
	$number = $number * 1024; #  先將原本 kB 改成 B
    return int($number + .5);
}

