#!/usr/bin/perl
# 16:51 2008/7/21
# Jonathan Tsai

$sarver = substr(`/bin/rpm -q sysstat`,8,5);

$mrtgline1=`/usr/bin/sar -u 1 3 | grep Average | awk '{print \$6}'`;
$mrtgline1=round($mrtgline1)."\n";
if ($sarver gt "6.1.0") {
	# 6.1.1 New field added to sar: %steal.  (http://pagesperso-orange.fr/sebastien.godard/changelog.html)
	$mrtgline2=`/usr/bin/sar -u 1 3 | grep Average | awk '{print \$8}'`;
}
else {
	$mrtgline2=`/usr/bin/sar -u 1 3 | grep Average | awk '{print \$7}'`;
}
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

