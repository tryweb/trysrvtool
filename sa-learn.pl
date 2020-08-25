#!/usr/bin/perl
#
# Train SpamAssassin
# Ref - http://www.ichiayi.com/wiki/tech/train_spamassassin
# 
# Ver 1.01
# 15:59 2016/11/08
# Jonathan Tsai
#
# SVN Info - $Id: sa-learn.pl 298 2016-11-08 08:15:52Z jonathan $
#

$g_spam_box = '/var/spool/mail/spam';
$g_nospam_box = '/var/spool/mail/nospam';
$cmd_sa_learn = '/usr/bin/sa-learn';
$cmd_sa_update = '/usr/bin/sa-update';
$cmd_true = '/bin/true';

# autopack 本身版本資訊
$prg_name = substr($0, rindex($0,"/")+1);
$prg_ver = '1.00';
@prg_svn_id = split(' ', '$Id: sa-learn.pl 298 2016-11-08 08:15:52Z jonathan $');
$prg_svn_date = $prg_svn_id[3].' '.$prg_svn_id[4];
$prg_svn_rev = $prg_svn_id[2];
$g_ver = $prg_ver.'.'.$prg_svn_rev.' ('.$prg_svn_date.')';

showMsg("$prg_name ver $g_ver\n");

# Check command
if (!-e $cmd_sa_learn) {
	showMsg("Command [$cmd_sa_learn] does not exist!");
	exit;
}
if (!-e $cmd_sa_update) {
	showMsg("Command [$cmd_sa_update] does not exist!");
	exit;
}
if (!-e $cmd_true) {
	showMsg("Command [$cmd_true] does not exist!");
	exit;
}

# Check spam-mbox
$g_todo = 0;
if (defined($g_spam_box)) {
	if (!-e $g_spam_box) {
		showMsg("File [$g_spam_box] does not exist!");
		exit;
	}
	$v_size = -s $g_spam_box;
	if ($v_size>0) {
		$g_todo = 1;
	}
}

if (defined($g_nospam_box)) {
	if (!-e $g_nospam_box) {
		showMsg("File [$g_nospam_box] does not exist!");
		exit;
	}
	$v_size = -s $g_nospam_box;
	if ($v_size>0) {
		$g_todo = 1;
	}
}


if ($g_todo) {
	$t_msg = `$cmd_sa_learn --spam --mbox $g_spam_box 2>&1`;
	if ($t_msg ne '') {
		showMsg('Learn SPAM Box:', $t_msg);
	}

	$t_msg = `$cmd_true > $g_spam_box 2>&1`;
	if ($t_msg ne '') {
		showMsg('Empty SPAM Box:', $t_msg);
	}

	$t_msg = `$cmd_sa_learn --ham --mbox $g_nospam_box 2>&1`;
	if ($t_msg ne '') {
		showMsg('Learn Not SPAM Box:', $t_msg);
	}

	$t_msg = `$cmd_true > $g_nospam_box 2>&1`;
	if ($t_msg ne '') {
		showMsg('Empty Not SPAM Box:', $t_msg);
	}

	#$t_msg = `$cmd_sa_update --nogpg 2>&1`;
	#if ($t_msg ne '') {
	#	showMsg('Update SpamAssassin:', $t_msg);
	#}
	$t_msg = `$cmd_sa_learn --sync 2>&1`;
	if ($t_msg ne '') {
		showMsg('Sync to SpamAssassin:', $t_msg);
	}

	$t_msg = `$cmd_sa_learn --dump magic 2>&1`;
	if ($t_msg ne '') {
		showMsg('Current SpamAssassin:', $t_msg);
	}
}
else {
	showMsg('No data!');
}

exit;


## perl common lib ##

#
#  10:31 2008/11/7
#
#  int stdDateTime($p_secval)
#  Return $StdTime
sub stdDateTime {
  my($p_secval) = @_;
  my(@arr_datetime, $i);

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

#
#  12:29 2016/11/02
#
#  showMsg($theMsg,@msgAry)
#  Return none
#
sub showMsg {
  my($theMsg, @msgAry) = @_;
  my($theMsgInfo, $theItem);

	$theMsgInfo = "";
	foreach $theItem (@msgAry) {
		$theMsgInfo .= "[$theItem] ";
	}
	$theMsgInfo = (length($theMsgInfo)>0)?" : $theMsgInfo":"";
	$theMsgInfo = "	$theMsg".$theMsgInfo;
	print(stdDateTime(time)."$theMsgInfo");
	if (substr($theMsgInfo, -1) ne "\n") {
		print("\n");
	}
	if (defined($g_logmsg)) {
		$g_logmsg .= stdDateTime(time)."$theMsgInfo";
		if (substr($theMsgInfo, -1) ne "\n") {
			$g_logmsg .= "\n";
		}
	}
	return;
}
