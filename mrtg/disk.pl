#!/usr/bin/perl
# Get DISK info for MRTG
# 17:52 2008/7/21
# Jonathan Tsai

$chkmountpt=!defined($ARGV[0])?"/":$ARGV[0];
$dfresult = `df -P -B 1 -T|grep -v "Mounted"|awk '{print \$7,\$1,\$6,\$4,\$5,\$2}'`;
@dfarr = split(/\n/, $dfresult);
$mrtgline="";
$idx=0;
while (length($mrtgline)==0 && $idx< @dfarr) {
        $dfline=$dfarr[$idx];
        ($mountpt, $fs, $capacity, $used, $available, $fstype) = split(/ /,$dfline);
        if ($mountpt eq $chkmountpt) {
                $mrtgline = "$used\n$available\n";
        }
        $idx++;
}
if (length($mrtgline)==0) {
        $mrtgline = "-1\n-1\n";
}
$UPtime=`/usr/bin/uptime | awk '{print \$3 " " \$4 " " \$5}'`;
$hostname=`/bin/hostname`;
print($mrtgline);
print($UPtime);
print("$chkmountpt ($fs) Capacity=$capacity on $hostname");

