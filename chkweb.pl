#!/usr/bin/perl
#
# 11:33 2014/8/5
# Jonathan Tsai
# Ver 1.10
#
# check web url keyword is exist or not
# Usage : chkweb.pl <config_file>
#  * <config_file> : default is chkweb.conf
#
# 1.00 (16:06 2014/7/30) First Version Release
# 1.10 (11:34 2014/8/5) Add Post a File function for Checking web alive
#
use Mail::Sendmail;

$prgname = substr($0, rindex($0,"/")+1);
$ver = "1.10 (2014/08/05)";

$p_setting = !defined($ARGV[0])?"/opt/trysrvtool/chkweb.set":$ARGV[0];
$p_config = !defined($ARGV[1])?"/opt/trysrvtool/chkweb.conf":$ARGV[1];

$conf_ChkTimeOut = 30;
$conf_SMTPServer = '127.0.0.1';
$conf_SYSUser = 'tryweb@ichiayi.com';
$conf_contentType = 'text/plain;charset=utf8';
$conf_subject1 = "%%id%% MailBox is oversize(%%size%%), system is moving it to [%%folder%%] folder";
$conf_subject2 = "%%id%% MailBox is moved to [%%folder%%] folder";

if (-e $p_config) {
	require($p_config);
}

@arr_config=();
if (-e $p_setting) {
	@tmp_config = split(/\n/, `/bin/cat $p_setting | /bin/grep -v "#"`);
	foreach $v_config (@tmp_config) {
		if (length($v_config)>0) {
			push @arr_config, $v_config;
		}
	}
}

if (@arr_config==0) {
	exit;
}

$g_msg = "# $prgname Ver $ver \n";
$v_msg = "";

foreach $v_conf_line (@arr_config) {
	($v_web_name, $v_check_url, $v_keyword, $v_mail_to, $v_mail_subject, $v_post_header, $v_post_file)=split(/\t/, $v_conf_line);
	$t_cmd = "/usr/bin/curl -k -s --connect-timeout $conf_ChkTimeOut";
	$v_post_header =~ s/ //g;
	if ($v_post_header ne '') {
		$t_cmd .= ' --header "'.$v_post_header.'"';
	}
	$v_post_file =~ s/ //g;
	if ($v_post_file ne '') {
		if (!-e $v_post_file) {
			$t_nowdatetime = `date +"%Y-%m-%d %H:%M:%S"`;
			$v_msg .= $t_nowdatetime."	Setting Err.. [$v_web_name] post file [$v_post_file] is not exist!\n";
			next;
		}
		$t_cmd .= ' --data @'.$v_post_file;
	}
	$t_msg = `$t_cmd "$v_check_url"`;
	if (index($t_msg, $v_keyword)<0) {
		$t_nowdatetime = `date +"%Y-%m-%d %H:%M:%S"`;
		$v_subject="[$prgname] Alert! ".$v_mail_subject;
		$v_subject =~ s/%%web_name%%/$v_web_name/g;
		$v_subject =~ s/%%check_url%%/$v_check_url/g;
		$v_subject =~ s/%%keyword%%/$v_keyword/g;
		$v_content ="$prgname Ver $ver \n\n";
		$v_content.="Check $v_web_name at $t_nowdatetime \n";
		$v_content.="Check URL : [$v_check_url] \n";
		$v_content.="Except Keyword : [$v_keyword] \n";
		$v_content.="Get URL Content : \n-----\n$t_msg\n-----\n";

		# Mail the message
		%mail = (	Smtp	=> $conf_SMTPServer,
				To	=> $v_mail_to,
				From    => $conf_SYSUser,
				Subject => $v_subject,
				'Content-Type' => $conf_contentType,
				Message => $v_content);
		$t_nowdatetime = `date +"%Y-%m-%d %H:%M:%S"`;
		$v_msg .= $t_nowdatetime."	Sending Msg..";
		$v_msg .= sendmail(%mail)?$Mail::Sendmail::log:$Mail::Sendmail::error;
		$v_msg .= "\n";
	}
}

if (length($v_msg)>0) {
	print($g_msg);
	print($v_msg);
	print("-----\n");
}