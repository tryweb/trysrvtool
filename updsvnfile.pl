#!/usr/bin/perl
#
# 11:09 2013/9/17
# Jonathan Tsai
# Ver 1.06
#
# auto commiting to svn server
#
# 1.00 (2006/4/3) First release version
# 1.01 (2007/3/14) Add svn user/passwd arugments
# 1.02 (2008/3/18) Add LANG env defined for supporting svn messages
# 1.03 (2008/7/18) Add read conf file function for specific forders
# 1.04 (2009/12/19) Support --config-dir svn option, Exp. ARGV[0] = config-dir / ARGV[1] = /root
# 1.05 (2012/8/30) Add /root/@hostname to be the default config svn path
# 1.06 (2013/9/17) Add cleanup before update, and Add non-interactive & trust-server-cert options with svn ci

$g_prgname = substr($0, rindex($0,"/")+1);
$g_ver = "1.06 (2013/9/17)";
$g_lang = "zh_TW.UTF-8";
$cmd_hostname = '/bin/hostname';

$p_svnid = !defined($ARGV[0])?"svnbot":$ARGV[0];
$p_svnpwd = !defined($ARGV[1])?"svnbot_adm":$ARGV[1];
$p_svnmsg = !defined($ARGV[2])?"$g_prgname $g_ver Auto Commit":$ARGV[2];
$p_config = !defined($ARGV[3])?"/opt/trysrvtool/updsvnfile.conf":$ARGV[3];

@arr_config=();
if (-e $p_config) {
	@tmp_config = split(/\n/, `/bin/cat $p_config | /bin/grep -v "#"`);
	foreach $v_config (@tmp_config) {
		$v_config =~ s/ |\r//g;
		if (length($v_config)>0) {
			push @arr_config, $v_config;
		}
	}
}

if (@arr_config==0) {
	@arr_config = ("/");
}

# check default svn path
chop($v_hostname = `$cmd_hostname`);
$v_default_path = '/root/'.$v_hostname.'/';
if (-e $v_default_path && !(grep { $_ eq $v_default_path } @arr_config)) {
	push @arr_config, $v_default_path;
}

$idx=0;
foreach $v_dir (@arr_config) {
	$idx++;
	$v_result = runsvn($v_dir);
	if (length($v_result)>0) {
		print($v_result);
	}
}

exit;


sub runsvn {
	local($p_dir) = @_;
	local($cmd_updfiles, $cmd_ciresult, $v_msg);

	$cmd_updfiles = `export LANG=$g_lang;/usr/bin/svn status -q $p_dir`;
	$v_msg = "";
	if (length($cmd_updfiles)>0) {
		if ($p_svnid eq 'config-dir') {
			$p_svnpwd .= '/.subversion';
			$cmd_ciresult = `export LANG=$g_lang;/usr/bin/svn cleanup $p_dir;/usr/bin/svn ci --non-interactive --trust-server-cert --config-dir \"$p_svnpwd\" -m \"$p_svnmsg\" $p_dir`;
		}
		else {
			$cmd_ciresult = `export LANG=$g_lang;/usr/bin/svn cleanup $p_dir;/usr/bin/svn ci --non-interactive --trust-server-cert --username \"$p_svnid\" --password \"$p_svnpwd\" -m \"$p_svnmsg\" $p_dir`;
		}
		$v_msg .= "DIR:[$p_dir]\n";
		$v_msg .= "[$p_svnmsg]:\n";
		$v_msg .= "$cmd_ciresult\n";
	}
	
	return($v_msg);
}
