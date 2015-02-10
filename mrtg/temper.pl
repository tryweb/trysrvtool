#!/usr/bin/perl
# Get temperature info for MRTG
# 23:39 2013/5/31
# Jonathan Tsai

$chkmode=!defined($ARGV[0])?"sensors":$ARGV[0];

if ($chkmode eq "sensors") {
	$chkkey=!defined($ARGV[1])?"Temp":$ARGV[1];
	# Note : You Must config /etc/sensors.conf Let temp -> CPU Temp (2 words)
	# M/B Temp: 
	# CPU Temp:
	$keycol=!defined($ARGV[2])?3:$ARGV[2]; 
	$result = `/usr/bin/sensors | /bin/grep $chkkey|awk '{print \$$keycol}'`;
	$result =~ s/\+|°C//g;
	print_info($result);
}
elsif ($chkmode eq "ups") {
	# SmartUPS
	$result = `/bin/cat /var/log/apcupsd.status | /bin/grep ITEMP|awk '{print \$3}'`;
	print_info($result);
}
elsif ($chkmode eq "scsi") {
	$chkdev=!defined($ARGV[1])?"/dev/sda":$ARGV[1];
	$chkkey=!defined($ARGV[2])?"Temperature":$ARGV[2];
	# SCSI / IDE HD
	$result = `/usr/sbin/smartctl -a $chkdev | /bin/grep $chkkey | /bin/grep Current|awk '{print \$4}'`;
	print_info($result);
}
elsif ($chkmode eq "sata") {
	$chkdev=!defined($ARGV[1])?"/dev/sda":$ARGV[1];
	$chkkey=!defined($ARGV[2])?"Temperature_Celsius":$ARGV[2];
	# SATA HD
	$result = `/usr/sbin/smartctl -a -d ata $chkdev | /bin/grep $chkkey|awk '{print \$10}'`;
	print_info($result);
}
elsif ($chkmode eq "ata") {
	$chkdev=!defined($ARGV[1])?"/dev/hda":$ARGV[1];
	$chkkey=!defined($ARGV[2])?"Temperature_Celsius":$ARGV[2];
	# SATA HD
	$result = `/usr/sbin/smartctl -a -d ata $chkdev | /bin/grep $chkkey|awk '{print \$10}'`;
	print_info($result);
}
else {
	print("-1\n-1\n");
}
$UPtime=`/usr/bin/uptime | awk '{print \$3 " " \$4 " " \$5}'`;
$hostname=`/bin/hostname`;
print($UPtime);
print("$hostname");


sub print_info {
    my($result) = @_;
    local($idx, $item);

	$idx=0;
	foreach $item (split(/\n/, $result)) {
		$idx++;
		$item = round($item);
		print($item."\n");
	}
	if ($idx==0) {
		print("0\n0\n");
	}
	elsif ($idx==1) {
		print("0\n");
	}

    return;
}

sub round {
    my($number) = @_;
    return int($number + .5);
}

