#!/usr/bin/perl
#
# 10:39 2008/10/4
# Jonathan Tsai
# Ver 1.00
#
# auto dns file and restart dns server
#
# 1.00 (2008/10/4) First release version

$g_prgname = substr($0, rindex($0,"/")+1);
$g_ver = "1.00 (2008/10/4)";

$p_config = !defined($ARGV[0])?"/opt/trysrvtool/upddnsfile.conf":$ARGV[0];

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
	exit;
}

$idx=0;
$isModify=0;
foreach $v_info (@arr_config) {
	$idx++;
	$v_result = runupd($v_info);
	if (length($v_result)>0) {
		print($v_result);
		$isModify++;
	}
}

if ($isModify>0) {
# restart DNS
	$msg = `service named restart`;
	print("----\n[$msg]----\n");
}

exit;


sub runupd {
	local($p_config) = @_;
	local($v_dns_config_file, $v_record_name, $v_get_ip_url);
	local($v_getIP, $v_msg);

	($v_dns_config_file, $v_record_name, $v_get_ip_url) = split(/\t| /, $p_config);
	$v_getIP = `/usr/bin/curl -s "$v_get_ip_url"`;
	if (length($v_getIP)<7 ||length($v_getIP)>15) {
		print("Error:get IP($v_getIP) is wrong!\n");
		return;
	}
	if (!-e $v_dns_config_file) {
		print("Error:DNS config file($v_dns_config_file) is not exist!\n");
		return;
	}
	$v_dns_config_data = `/bin/cat $v_dns_config_file`;
	$v_dns_config_edit = "";
	$v_time_flag = 0;
	$v_nowdatetime = the_datetime(time);
	foreach $v_dns_line (split(/\n/, $v_dns_config_data)) {
		$v_trim_line = $v_dns_line;
		$v_trim_line =~ s/ |\t//g;
		if ($v_time_flag==1) {
			$v_dns_config_edit .= "\t\t\t\t$v_nowdatetime\t\t; serial (d. adams)\n";
			$v_time_flag=0;
		}
		elsif (index($v_dns_line, "SOA")>0){
			$v_dns_config_edit .= $v_dns_line."\n";
			$v_time_flag=1;
		}
		elsif (substr($v_dns_line,0,length($v_record_name)+1) eq $v_record_name."\t") {
			$v_nowIP = (split(/\t/,$v_dns_line))[4];
			if ($v_nowIP ne $v_getIP) {
				$v_dns_config_edit .= "$v_record_name\t\tIN\tA\t$v_getIP\t; Auto modified on $v_nowdatetime\n";
				$v_msg="$v_record_name:[$v_nowIP]->[$v_getIP]\n";
			}
		}
		elsif (length($v_trim_line)>0) {
			$v_dns_config_edit .= $v_dns_line."\n";
		}
	}
	if (length($v_msg)>0) {
		#print("-----\n$v_dns_config_edit-----\n");
		open(FILE, ">$v_dns_config_file");
		print FILE $v_dns_config_edit;
		close(FILE);
	}
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
  return($t_datetime[5].$t_datetime[4].$t_datetime[3].$t_datetime[2].$t_datetime[1]);
}
