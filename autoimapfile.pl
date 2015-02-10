#!/usr/bin/perl
#
# 15:01 2009/11/04
# Jonathan Tsai
# Ver 1.01
#
# auto move spoole/mail/userid -> home/userid/mail/yyyymmdd
# Usage : autoimapfile.pl <config_file>
#  * <config_file> : default is autoimapfile.conf
#
# 1.00 (2009/10/27) First Version Release
#
use Mail::Sendmail;

$prgname = substr($0, rindex($0,"/")+1);
$ver = "1.01 (2009/11/04)";
$p_config = !defined($ARGV[0])?"/opt/trysrvtool/autoimapfile.conf":$ARGV[0];

#---- could be overwrite by autoimapfile.conf 
$conf_spool_mail = '/var/spool/mail/';
$conf_home = '/home/';
$conf_limitsize = 100000000; # 100 MBytes
$conf_mailgroup = 'mail';
$conf_mailmode = '600'; # -rw-------
$conf_check_id = '';
$conf_toSYSUser = 0;

$cmd_ls = '/bin/ls';
$cmd_mv = '/bin/mv';
$cmd_cp = '/bin/cp';
$cmd_mkdir = '/bin/mkdir';
$cmd_touch = '/bin/touch';
$cmd_chown = '/bin/chown';
$cmd_chmod = '/bin/chmod';

$conf_SMTPServer = '127.0.0.1';
$conf_MailDN = '@ichiayi.com';
$conf_SYSUser = 'tryweb@ichiayi.com';
$conf_contentType = 'text/plain;charset=big5';
$conf_subject1 = "%%id%% MailBox is oversize(%%size%%), system is moving it to [%%folder%%] folder";
$conf_subject2 = "%%id%% MailBox is moved to [%%folder%%] folder";
#----

if (-e $p_config) {
	require($p_config);
}

$g_msg = "# $prgname Ver $ver \n";
$v_msg = "";

# Scan spool_mail
	@arr_filelist = split("\n",`$cmd_ls "$conf_spool_mail"`);
	$v_fileNum = @arr_filelist;
	foreach $v_fileName (@arr_filelist) {
		if (defined($conf_check_id) && $conf_check_id ne "") {
			if (index($conf_check_id, ",$v_fileName,")>=0) {
				$v_msg .= procIt($v_fileName);
			}
		}
		else {
				$v_msg .= procIt($v_fileName);			
		}
	}

if (length($v_msg)>0) {
	print($g_msg);
	print("-----\n");
	print($v_msg);
	print("-----\n");
}

sub procIt {
	local($p_id) = @_;
	local($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks,$v_msg,$v_tmpfile,$v_folder,$idx,$v_subject,$v_receiver);
	
	($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)=stat($conf_spool_mail.$p_id);
	if ($size>=$conf_limitsize) {
		$v_tmpfile = $p_id.'_'.$$.'_'.int(rand()*100000);
		$v_folder = substr(stdDateTime(time),0,10);
		$v_folder =~ s/-//g;
		$idx=1;
		while (-e $conf_home.$p_id.'/mail/'.$v_folder.'-'.$idx) {
			$idx++;
		}
		$v_folder .= '-'.$idx;
		$v_receiver = $p_id.$conf_MailDN;
		$v_subject = $conf_subject1;
		$v_subject =~ s/%%id%%/$p_id/g;
		$v_subject =~ s/%%size%%/$size/g;
		$v_subject =~ s/%%folder%%/$v_folder/g;

		$v_msg = stdDateTime(time)."	[$p_id] : ($size) -> [$v_tmpfile] -> [$v_folder]\n";
		$v_msg .= `$cmd_mv $conf_spool_mail$p_id $conf_spool_mail$v_tmpfile 2>&1`;
		$v_msg .= `$cmd_touch $conf_spool_mail$p_id; $cmd_chown $p_id:$conf_mailgroup $conf_spool_mail$p_id; $cmd_chmod $conf_mailmode $conf_spool_mail$p_id 2>&1`;
		# Mail the 1st message
		%mail = (	Smtp	=> $conf_SMTPServer,
				To	=> $v_receiver,
				From    => $conf_SYSUser,
				Subject => $v_subject,
				'Content-Type' => $conf_contentType,
				Message => $v_msg);
		$v_msg .= stdDateTime(time)."	Sending 1st Msg..";
		$v_msg .= sendmail(%mail)?$Mail::Sendmail::log:$Mail::Sendmail::error;
		$v_msg .= "\n";

		$v_msg .= `$cmd_mkdir -p $conf_home$p_id/mail/ 2>&1`;
		$v_msg .= `$cmd_mv $conf_spool_mail$v_tmpfile $conf_home$p_id/mail/$v_folder 2>&1`;

		$v_subject = $conf_subject2;
		$v_subject =~ s/%%id%%/$p_id/g;
		$v_subject =~ s/%%size%%/$size/g;
		$v_subject =~ s/%%folder%%/$v_folder/g;
		# Mail the 2nd message
		%mail = (	Smtp	=> $conf_SMTPServer,
				To	=> $v_receiver,
				From    => $conf_SYSUser,
				Subject => $v_subject,
				'Content-Type' => $conf_contentType,
				Message => $v_msg);
		$v_msg .= stdDateTime(time)."	Sending 2nd Msg..";
		$v_msg .= sendmail(%mail)?$Mail::Sendmail::log:$Mail::Sendmail::error;
		$v_msg .= "\n";

		# Send to SYSUser
		if ($conf_toSYSUser==1){
			%mail = (       Smtp    => $conf_SMTPServer,
				To      => $conf_SYSUser,
				From    => $conf_SYSUser,
				Subject => $v_subject,
				'Content-Type' => $conf_contentType,
				Message => $v_msg);
			$v_msg .= stdDateTime(time)."   Sending SYSUser Msg..";
			$v_msg .= sendmail(%mail)?$Mail::Sendmail::log:$Mail::Sendmail::error;
			$v_msg .= "\n";
		}
	}

	return($v_msg);
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

