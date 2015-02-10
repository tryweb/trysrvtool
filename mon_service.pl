#!/usr/bin/perl
#
# 14:13 2009/6/12
# Jonathan Tsai
# Ver 1.02
#
# monitor service and restart it
# Usage : mon_service.pl <config_file>
#  * <config_file> : default is mon_service.conf
#
# 1.00 (2008/10/24) First Version Release
#

$prgname = substr($0, rindex($0,'/')+1);
$prgpath = substr($0, 0, rindex($0,'/'));
$ver = "1.02 (2009/6/12)";
$t_conffile = 
$p_config = !defined($ARGV[0])?"/opt/trysrvtool/mon_service.conf":$ARGV[0];

@arr_config=();
if (-e $p_config) {
	@tmp_config = split(/\n/, `/bin/cat $p_config | /bin/grep -v "#"`);
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
	($v_service_name, $v_check_ip, $v_check_port, $v_input_cmd, $v_except_msg_keyword, $v_run_cmd)=split(/\t/, $v_conf_line);
	$t_msg = `echo $v_input_cmd | nc $v_check_ip $v_check_port`;
	if (index($t_msg, $v_except_msg_keyword)<0) {
		$t_nowdatetime = `date +"%Y-%m-%d %H:%M:%S"`;
		$t_result=`$v_run_cmd`;
		$v_msg .= $t_nowdatetime."	Run:[".$v_run_cmd."]\n";
		$v_msg .= $t_result;
	}
}

if (length($v_msg)>0) {
	print($g_msg);
	print($v_msg);
	print("-----\n");
}
