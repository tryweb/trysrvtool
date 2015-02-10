#!/usr/bin/perl -w
# 讀取哪個 IP 在哪天讀過目前 web server 的紀錄
# Ver 1.00
# 上午 09:50 2007/6/26
# Jonathan Tsai.
#
$prgname = "Check IP on Web logs";
$verinfo = "Ver 1.00 (2007/6/26)";
$httpconf = "/etc/httpd/conf/httpd.conf";
$defaultlog = "/var/log/httpd/access_log";
$rmcmd = "/bin/rm";
$tmpdir = "/tmp/";

$ipaddr=$ARGV[0]; # aaa.bbb.ccc.ddd
$lookdate=$ARGV[1]; # yyyymmdd 預設是今天

if (length($ipaddr)==0) {
	print($prgname." ".$verinfo."\n");
	print("Usage : $0 ipaddr [date]\n");
	exit;
}
if (length($lookdate)==0) {
	$lookdate = `/bin/date +%Y%m%d`;
	$lookdate =~ s/\n|\r//g;
}

# 讀取 $httpconf 將所有 log file 檔列出
$http_conf_data = `/bin/cat $httpconf | /bin/grep CustomLog`;
@t_arr = split(/\n/, $http_conf_data);
$t_chk_log_list = "";
$t_idx = 0;
foreach $t_log_file (@t_arr) {
	$t_log_file =~ s/CustomLog |\"\|\/usr\/local\/sbin\/cronolog | combined//g;
	$t_log_file =~ s/\%Y\%m\%d\"/$lookdate/;
	$t_log_file =~ s/( )*#/#/g;
	$t_log_file = ($t_log_file eq "logs/access_log")?$defaultlog:$t_log_file;
	if ((substr($t_log_file,0,1) ne "\#") && (index($t_chk_log_list, $t_log_file)<0)) {
		$t_idx ++;
		$t_chk_log_list .= "[$t_log_file]";
		print("($t_idx) Check ip:[$ipaddr] in [$t_log_file]...\n");
		$t_get_info = `/bin/cat $t_log_file | /bin/grep $ipaddr`;
		$t_get_info = (length($t_get_info)==0)?"Not found!":$t_get_info;
		print("-----\n$t_get_info\n-----\n");
	}
}
