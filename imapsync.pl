#!/usr/bin/perl
#
# 18:53 2018/06/22
# Jonathan Tsai
# Ver 1.00
#
# batch call imapsync https://imapsync.lamiral.info/
# Usage : imapsync.pl <config_file>
#  * <config_file> : default is imapsync.conf
#
# 1.00 (2018/06/22) First Version Release
#
# SVN Info - $Id: imapsync.pl 302 2017-06-11 15:59:59Z jonathan $
#

$prgname = substr($0, rindex($0,"/")+1);
$ver = "1.00 (2018/06/22)";
$p_config = !defined($ARGV[0])?"/opt/trysrvtool/imapsync.conf":$ARGV[0];

#---- could be overwrite by imapsync.conf 
$conf_syncinfo_dir = '/root/sync_info/';
$conf_host1 = 'mail.srcmail.com.tw';
$conf_host2 = '192.168.0.236';
@arr_user = ('admin', 'jonathan');
$cmd_imapsync = '/usr/bin/imapsync';
#----

if (-e $p_config) {
	require($p_config);
}

$g_msg = "# $prgname Ver $ver \n";
$v_msg = "";

print($g_msg);
	foreach $v_user (@arr_user) {
		# Example : 
		# imapsync --host1 mail.srcmail.com.tw --user1 jonathan --passfile1 /root/sync_info/jonathan --host2 192.168.0.236 --user2 jonathan --passfile2 /root/sync_info/jonathan
		print(stdDateTime()."	sync :[$v_user]..\n");
		$v_cmd = "$cmd_imapsync --host1 $conf_host1 --user1 $v_user --passfile1 $conf_syncinfo_dir"."$v_user --host2 $conf_host2 --user2 $v_user --passfile2 $conf_syncinfo_dir"."$v_user";
		`$v_cmd`;
	}
print(stdDateTime()."	End.\n");
exit;

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

