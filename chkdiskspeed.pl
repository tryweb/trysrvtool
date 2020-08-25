#!/usr/bin/perl
#
# 12:50 2018/09/12
# Jonathan Tsai
# Ver 1.00
#
# Check Disk Write Seepd
# Default chk file: /tmp/t.dump
#
# 1.00 (2018/9/12) First release version

$g_prgname = substr($0, rindex($0,"/")+1);
$g_ver = "1.00 (2018/9/12)";
$cmd_hostname = '/bin/hostname';
$cmd_dd = '/bin/dd';
$cmd_rm = '/bin/rm -f';

print("$g_prgname Ver $g_ver\n");

chop($v_hostname = `$cmd_hostname`);
$v_default_dumpfile = '/tmp/t.dump';
$p_dumpfile = !defined($ARGV[0])?$v_default_dumpfile:$ARGV[0];

print(stdDateTime()." Check $v_hostname : [$p_dumpfile]\n");

# write 2GB 
@arr_bs = ('4k', '8k', '16k', '32k', '64k', '128k', '256k', '512k', '1024k', '2048k');
@arr_count = (500000, 250000, 125000, 62500, 31250, 15625, 7813, 3906, 1953, 977);
@arr_speed = ();

$st = `$cmd_rm -f $p_dumpfile`;
print("\n");
for ($i=0; $i<10; $i++) {
	print (stdDateTime().' #####Test '.($i+1)." ..".$arr_bs[$i].' x '.$arr_count[$i]."\n");
	$st = `$cmd_dd if=/dev/zero of=$p_dumpfile bs=$arr_bs[$i] count=$arr_count[$i] 2>&1`;
	$st .= `$cmd_rm -f $p_dumpfile 2>&1`;
	$arr_speed[$i]=-1;
	if (length($st)>0) {
		$arr_speed[$i]=getSpeed($st);
		print("------------\n$st\n------------\n");
	}
}
print(stdDateTime()." Check $v_hostname [$p_dumpfile] Finish..\n");
for ($i=0; $i<10; $i++) {
	print(($i+1)."\t".$arr_bs[$i].' x '.$arr_count[$i]."\t".$arr_speed[$i]."\n");
}
print(stdDateTime()." End..\n");

exit;

#
# getSpeed -> 75.5
#------------------------
# 1953+0 records in
# 1953+0 records out
# 2047868928 bytes (2.0 GB) copied, 27.1328 s, 75.5 MB/s
# ....
# 2048000000 bytes (2.0 GB, 1.9 GiB) copied, 1.93291 s, 1.1 GB/s
#------------------------
#
sub getSpeed {
  local($p_msg) = @_;
  local($i, $j, $t1, $t2);

	$t1 = substr($p_msg, index($p_msg,'s,')+2);
	$i = rindex($t1, 'GB/s');
	if ($i>0) {
		$j = 1000;
	}
	else {
		$i = rindex($t1, 'MB/s');
		$j = 1;
	}
	$t1 = substr($t1, 0, $i);
	$t1 = $t1 * $j;
	
	return($t1);
}

#
#  10:31 2008/11/7
#
#  int stdDateTime($p_secval)
#  Return $StdTime
sub stdDateTime {
  local($p_secval) = @_;
  local(@arr_datetime, $i);

  $p_secval = defined($p_secval)?$p_secval:time;
  @arr_datetime = localtime($p_secval);
  $arr_datetime[4] ++;
  $arr_datetime[5] += 1900;

  for($i=0; $i<6; $i++) {
    if (length($arr_datetime[$i]) == 1) {
      $arr_datetime[$i] = '0'.$arr_datetime[$i];
    }
  }
  return($arr_datetime[5].'-'.$arr_datetime[4].'-'.$arr_datetime[3].' '.$arr_datetime[2].':'.$arr_datetime[1].':'.$arr_datetime[0]);
}
