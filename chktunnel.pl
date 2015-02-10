#!/usr/bin/perl
# -- User define --
$g_linksrv = 'trybox\@10.1.1.33 -p 22';
$g_srvport = 9005;
$g_chkKeyWord = 'SSH-1.99-OpenSSH_4.5';
#------------------

$g_chkCmd = "ssh $g_linksrv \"echo -n | nc localhost $g_srvport\"";
$g_runCmd = "ssh -nNT -R $g_srvport:localhost:22 $g_linksrv";
$g_result = `$g_chkCmd 2>&1`;
print ("cmd:[$g_chkCmd] result:[$g_result]\n");
if (index($g_result, $g_chkKeyWord)<0) {
	# Call Reconnect..
	$t_now = `date +"%Y%m%d %H:%M:%S"`;
	$t_now =~ s/\n|\r//g;
	print ($t_now." Connecting..\n");
	`$g_runCmd &`;
}
