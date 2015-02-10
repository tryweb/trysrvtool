#!/usr/bin/perl
# Fix mrtg.cfg for net device 
# 21:58 2014/11/5
# Jonathan Tsai
#
# 14:08 2013/12/26 fixed bug for no #id after reboot
# 16:22 2014/5/2 auto detect add or remove defined vnet
# 21:58 2014/11/5 using virsh and vnet template to update mrtg.cfg
#

$g_mrtg_file='/etc/mrtg/mrtg.cfg';
$g_is_changed=0;
# Now Status
# cfgmaker public@localhost | grep '### Interface' | grep 'vnet' | awk '{print $3 " " $6 " " $15}'
#7 'vnet0' 'fe-54-00-42-64-9f'
#8 'vnet1' 'fe-54-00-59-8f-d0'
#

$g_mrtg_temp = <<'End_of_text';
### Interface %%id%% >> Descr: '%%if_name%%' | Name: '%%domain%%_%%dev%%' | Ip: '' | Eth: '%%mac_addr%%' ###

Target[%%domain%%_%%dev%%]: %%id%%:public@localhost:
SetEnv[%%domain%%_%%dev%%]: MRTG_INT_IP="" MRTG_INT_DESCR="%%if_name%%"
MaxBytes[%%domain%%_%%dev%%]: 1250000
Title[%%domain%%_%%dev%%]: Traffic Analysis for %%domain%%
PageTop[%%domain%%_%%dev%%]: <h1>Traffic Analysis for %%domain%%</h1>
                <div id="sysdetails">
                        <table>
                                <tr>
                                        <td>System:%%domain%%</td>
                                        <td>xpc-sh67-i7 in ichiayi</td>
                                </tr>
                                <tr>
                                        <td>Maintainer:</td>
                                        <td>Root &lt;root@lichiayi.com&gt;</td>
                                </tr>
                                <tr>
                                        <td>Description:</td>
                                        <td>%%if_name%%  </td>
                                </tr>
                                <tr>
                                        <td>ifType:</td>
                                        <td>ethernetCsmacd (6)</td>
                                </tr>
                                <tr>
                                        <td>ifName:</td>
                                        <td>%%dev%%</td>
                                </tr>
                                <tr>
                                        <td>Max Speed:</td>
                                        <td>1250.0 kBytes/s</td>
                                </tr>
                        </table>
                </div>
End_of_text

%hash_now_id=();
%hash_now_if_name=();
%hash_now_domain=();
%hash_now_dev=();
@arr_now=();
$cmd_msg=`cfgmaker public\@localhost | grep '### Interface' | grep 'vnet' | awk '{print \$3 " " \$6 " " \$15}'`;
foreach $line (split("\n", $cmd_msg)) {
	($id, $if_name, $mac_addr) = split(" ", $line);
	$if_name =~ s/'//g;
	$mac_addr =~ s/'//g;
	$hash_now_id{$mac_addr}=$id;
	$hash_now_if_name{$mac_addr}=$if_name;
}

# virsh list --name
#kvm-svn
#kvm-nginx
$cmd_msg=`virsh list --name`;
$idx=0;
foreach $t_domain (split("\n", $cmd_msg)) {
# virsh domiflist '<domain>' | grep 'vnet' | awk '{print $1 " " $3 " " $5}'
#vnet6 br0 52:54:00:59:8f:d0
#vnet7 servernet01 52:54:00:9a:96:7b
	$t_msg=`virsh domiflist '$t_domain' | grep 'vnet' | awk '{print \$1 " " \$3 " " \$5}'`;
	foreach $line (split("\n", $t_msg)) {
		($if_name, $dev, $mac_addr) = split(" ", $line);
		$mac_addr =~ s/:/-/g;
		$mac_addr = 'fe'.substr($mac_addr,2);
		if ($hash_now_if_name{$mac_addr} ne $if_name) {
			print("[$mac_addr] : ifname error!!! $hash_now_if_name{$mac_addr} ne $if_name\n");
			exit;
		}
		$hash_now_domain{$mac_addr}=$t_domain;
		$hash_now_dev{$mac_addr}=$dev;
		$arr_now[$idx]="$t_domain $dev $hash_now_id{$mac_addr} $hash_now_if_name{$mac_addr} $mac_addr";
		$idx++;
	}
}

@arr_remove=();
@arr_modify=();
$remove_idx=0;
$modify_idx=0;
%hash_file_mac_addr=();
# Check mrtg.cfg Status
# cat /etc/mrtg/mrtg.cfg | grep '### Interface' | grep 'vnet' | awk '{print $3 " " $6 " " $15}'
$cmd_msg=`cat $g_mrtg_file | grep '### Interface' | grep 'vnet' | awk '{print \$3 " " \$6 " " \$15}'`;
foreach $line (split("\n", $cmd_msg)) {
	($id, $if_name, $mac_addr) = split(" ", $line);
	$if_name =~ s/'//g;
	$mac_addr =~ s/'//g;
	$hash_file_mac_addr{$mac_addr}="$id $if_name $mac_addr";
	if (!defined($hash_now_id{$mac_addr})) {
		print("Remove $id $if_name $mac_addr !!!\n");
		@arr_remove[$remove_idx]="$id $if_name $mac_addr";
		$remove_idx++;
		$g_is_changed=1;
	}
	if ($hash_now_id{$mac_addr} ne $id || $hash_now_if_name{$mac_addr} ne $if_name ) {
		print("Modify [$mac_addr]:$id -> ".$hash_now_id{$mac_addr}." , $if_name -> ".$hash_now_if_name{$mac_addr}."...");
		@arr_modify[$modify_idx]="$id $if_name $mac_addr $hash_now_domain{$mac_addr} $hash_now_dev{$mac_addr} $hash_now_id{$mac_addr} $hash_now_if_name{$mac_addr} $mac_addr";
		$modify_idx++;
		$g_is_changed=1;
	}
}

@arr_add=();
$add_idx=0;
foreach $line (@arr_now) {
	($domain, $dev, $id, $if_name, $mac_addr) = split(" ", $line);
	if (!defined($hash_file_mac_addr{$mac_addr})) {
		print("Add $domain $dev $id $if_name $mac_addr !!!\n");
		@arr_add[$add_idx]="$domain $dev $id $if_name $mac_addr";
		$add_idx++;
		$g_is_changed=1;
	}
}


if ($g_is_changed==1) {
	$mrtg_msg=`cat $g_mrtg_file`;
	if ($remove_idx>0) {
		($mrtg_msg, $result)=fix_mrtg('Remove', $mrtg_msg, @arr_remove);
		print("$result\n");
	}
	
	if ($modify_idx>0) {
		($mrtg_msg, $result)=fix_mrtg('Modify', $mrtg_msg, @arr_modify);
		print("$result\n");
	}
	
	if ($add_idx>0) {
		($mrtg_msg, $result)=fix_mrtg('Add', $mrtg_msg, @arr_add);
		print("$result\n");
	}

	# renew mrtg.cfg
	`cat $g_mrtg_file > $g_mrtg_file.bak`;
	if(!open(CFG, ">".$g_mrtg_file)){
		print("Cannot open file [$g_mrtg_file]\n");
		exit;
	}
	print CFG $mrtg_msg;
	close (CFG);
}

exit;

#
#### Interface 6 >> Descr: 'vnet0' | Name: '' | Ip: '' | Eth: 'fe-54-00-83-c7-fa' ###
#
#Target[localhost_6]: 6:public@localhost:
#
sub fix_mrtg {
	local($p_cmd, $p_mrtg, @p_array) = @_;
	local($v_result, $v_mrtg, $t_line, $v_line, $v_section);
	local($v_id, $v_if_name, $v_mac_addr, $v_new_id, $v_new_if_name, $v_domain, $v_dev);

	$v_mrtg=$p_mrtg;
	if ($p_cmd eq 'Remove') {
		foreach $v_line (@p_array) {
			# Remove : $id $if_name $mac_addr
			($v_id, $v_if_name, $v_mac_addr)=split(' ', $v_line);
			$t_line = "### Interface $v_id >> Descr: '$v_if_name'";
			#### Interface 6 >> Descr: 'vnet0' | Name: '' | Ip: '' | Eth: 'fe-54-00-83-c7-fa' ###
			($v_mrtg, $v_result)=sec_mrtg('Remove', $v_mrtg, $t_line);
		}
	}
	elsif ($p_cmd eq 'Modify') {
		foreach $v_line (@p_array) {
			# Modify : $id $if_name $mac_addr $hash_now_domain{$mac_addr} $hash_now_dev{$mac_addr} $hash_now_id{$mac_addr} $hash_now_if_name{$mac_addr} $mac_addr
			($v_id, $v_if_name, $v_mac_addr, $v_domain, $v_dev, $v_new_id, $v_new_if_name)=split(' ', $v_line);
			$t_line = "### Interface $v_id >> Descr: '$v_if_name'";
			#### Interface 6 >> Descr: 'vnet0' | Name: '' | Ip: '' | Eth: 'fe-54-00-83-c7-fa' ###
			$v_section = $g_mrtg_temp;
			$v_section =~ s/%%id%%/$v_new_id/g;
			$v_section =~ s/%%if_name%%/$v_new_if_name/g;
			$v_section =~ s/%%domain%%/$v_domain/g;
			$v_section =~ s/%%dev%%/$v_dev/g;
			$v_section =~ s/%%mac_addr%%/$v_mac_addr/g;
			($v_mrtg, $v_result)=sec_mrtg('Modify', $v_mrtg, $t_line, $v_section);
		}
	}
	elsif ($p_cmd eq 'Add') {
		$t_line = '';
		foreach $v_line (@p_array) {
			# Add: $domain $dev $id $if_name $mac_addr
			($v_domain, $v_dev, $v_id, $v_if_name, $v_mac_addr)=split(' ', $v_line);
			$v_section = $g_mrtg_temp;
			$v_section =~ s/%%id%%/$v_id/g;
			$v_section =~ s/%%if_name%%/$v_if_name/g;
			$v_section =~ s/%%domain%%/$v_domain/g;
			$v_section =~ s/%%dev%%/$v_dev/g;
			$v_section =~ s/%%mac_addr%%/$v_mac_addr/g;
			$t_line .= $v_section."\n\n";
		}
		($v_mrtg, $v_result)=sec_mrtg('Add', $v_mrtg, $t_line);
	}
	else {
		return($p_mrtg, 'Unknown cmd [$p_cmd]!!!');
	}

	return($v_mrtg, $v_result);
}
	
sub sec_mrtg {
	local($p_cmd, $p_mrtg, $p_line, $p_section) = @_;
	local($v_result, $v_mrtg, $t_line, $v_line, $v_section, $v_left, $v_right);

	$v_mrtg=$p_mrtg;
	if ($p_cmd eq 'Add') {
		$v_idx=rindex($v_mrtg, '</div>');
		if ($v_idx<0) {
			return($p_mrtg, 'Not Found(1)!');
		}
		$v_left = substr($v_mrtg, 0, $v_idx+length('</div>')+1);
		$v_right = substr($v_mrtg, $v_idx+length('</div>'));
		$v_mrtg = $v_left."\n\n".$p_line.$v_right;
	}
	else {
		$v_idx=index($v_mrtg, $p_line);
		if ($v_idx<0) {
			return($p_mrtg, 'Not Found(2)!');
		}
		#### Interface 6 >> Descr: 'vnet0' | Name: '' | Ip: '' | Eth: 'fe-54-00-83-c7-fa' ###
		#:
		#:
		#</div>
		#
		$v_left = substr($v_mrtg, 0, $v_idx);
		$v_idx=index($v_mrtg, "</div>\n\n", $v_idx+1);
		if ($v_idx<0) {
			return($p_mrtg, 'Not Found(3)!');
		}
		$v_right = substr($v_mrtg, $v_idx+length("</div>\n\n")+1);
		if ($p_cmd eq 'Modify') {
			$v_mrtg = $v_left.$p_section."\n\n".$v_right;
		}
		elsif ($p_cmd eq 'Remove') {
			$v_mrtg = $v_left.$v_right;
		}
		else {
			return($p_mrtg, 'cmd Error!');
		}
	}
	return($v_mrtg, 'OK!');
}
