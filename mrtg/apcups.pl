#!/usr/bin/perl
# Get APCUPSD info ( http://www.ichiayi.com/wiki/tech/apcupsd ) for MRTG
# 05:19 2008/7/22
# Jonathan Tsai

# default : "LOADPCT,BCHARGE"
# Volts : "LINEV    :,OUTPUTV"
# Other : "TIMELEFT,BATTV    :"

$apcupslog="/var/log/apcupsd.status";
$chkitem=!defined($ARGV[0])?"LOADPCT,BCHARGE":$ARGV[0];
$chkitem=~ s/\,/\|/g;

$itemresult = `cat $apcupslog|grep -P "$chkitem"|awk '{print \$3}'`;
foreach $item (split(/\n/, $itemresult)) {
	$item = round($item);
	print($item."\n");
}
$UPtime=`/usr/bin/uptime | awk '{print \$3 " " \$4 " " \$5}'`;
$hostname=`cat $apcupslog|grep -P "UPSNAME|MODEL|SERIALNO|FIRMWARE"|awk '{print \$3}'`;
$hostname=~ s/\n/ /g;
print($UPtime);
print("$hostname\n");

sub round {
    my($number) = @_;
    return int($number + .5);
}


