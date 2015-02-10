#!/usr/bin/perl
#
# 10:20 2012/9/13
# Jonathan Tsai
# Ver 1.03
#
# auto add system config file to svn server
# Default local svn work dir path /root/$hostname
#
# 1.00 (2012/8/30) First release version
# 1.01 (2012/9/11) Change Using --symbolic link to support cross disk
# 1.02 (2012/9/12) Add Auto Fix change to link svn ~ problem
# 1.03 (2012/9/13) Fix Bug

$g_prgname = substr($0, rindex($0,"/")+1);
$g_ver = "1.03 (2012/9/13)";
$g_lang = "zh_TW.UTF-8";
$cmd_hostname = '/bin/hostname';
$cmd_link = '/bin/ln';
$cmd_mkdir = '/bin/mkdir';
$cmd_svn = "export LANG=$g_lang;/usr/bin/svn";
$cmd_rm = '/bin/rm -f';

chop($v_hostname = `$cmd_hostname`);
$v_default_path = '/root/'.$v_hostname.'/';

$p_svnworkpath = !defined($ARGV[0])?$v_default_path:$ARGV[0];
$p_config = !defined($ARGV[1])?"/opt/trysrvtool/svnsysfile.conf":$ARGV[1];
$p_svnworkpath .= substr($p_svnworkpath,-1,1) ne '/'?'/':'';

# check default svn work dir path
if (!-e $p_svnworkpath) {
	print("SVN Work Dir [$p_svnworkpath] is not exist!\n");
	exit;
}
$t_msg = `$cmd_svn info $p_svnworkpath`;
print("-----\n".$t_msg."-----\n");
if (index($t_msg, 'URL:')<0) {
	exit;
}

$v_notfound=0;
$v_svnadd=0;
$v_svnadderr=0;
$v_svnskip=0;

@arr_config=();
if (-e $p_config) {
	@tmp_config = split(/\n/, `/bin/cat $p_config | /bin/grep -v "#"`);
	foreach $v_config (@tmp_config) {
		$v_config =~ s/ |\r//g;
		if (-e $v_config) {
			push @arr_config, $v_config;
		}
		elsif ($v_config ne '') {
			print("[$v_config] not found!\n");
			$v_notfound++;
		}
	}
}

$idx=0;
foreach $v_file (@arr_config) {
	$idx++;
	$v_result = runsvn($v_file);
	if (length($v_result)>0) {
		print($v_result);
	}
}

print("--------------------\n");
print("Not Found:\t$v_notfound\n");
print("Skip Files:\t$v_svnskip\n");
print("Add Error:\t$v_svnadderr\n");
print("SVN Add OK:\t$v_svnadd\n");
print("--------------------\n");

exit;

#	$v_msg = runlink($p_file, $p_workfile);
sub runlink {
	local($p_file, $p_workfile) = @_;
	local($v_msg, @tmp_arr, $t_path, $t_dir, $t_msg);
	
	if (!-e $p_file) {
		return("src file [$p_file] is not found!");
	}
	if (-e $p_workfile) {
		$v_msg = `$cmd_rm $p_workfile`;
		if ($v_msg ne '') {
			return($v_msg);
		}		
		#return("dest file [$p_workfile] is already exist!");
	}
	$p_workfile =~ s/\/\//\//g;
	@tmp_arr = split(/\//, $p_workfile);
	$t_path = '';
	foreach $t_dir (@tmp_arr) {
		if ($t_dir eq '') {
			next;
		}
		$t_path .= '/'.$t_dir;
		if ($t_path eq $p_workfile) {
			$v_msg = `$cmd_link $p_file $p_workfile`;
			if ($v_msg ne '') {
				return($v_msg);
			}
			$v_msg = `$cmd_svn status $p_workfile`;
			if (substr($v_msg,0,1) eq '~') {
				$t_msg = `$cmd_rm $p_workfile`;
				$t_msg .= `$cmd_svn update $p_workfile`;
				$t_msg .= `$cmd_svn del $p_workfile`;
				$t_msg .= `$cmd_svn ci -m 'Auto Fix' $p_workfile`;
				$v_msg = `$cmd_link $p_file $p_workfile`;
				if ($v_msg ne '') {
					return($t_msg.$v_msg);
				}
			}
		}
		elsif (-e $t_path) {
			next;
		}
		else {
			$v_msg = `$cmd_mkdir $t_path`;
			if ($v_msg ne '') {
				return($v_msg);
			}
		}
	}
	return('');
}

#	$v_msg = svnadd($p_workfile);
sub svnadd {
	local($p_workfile) = @_;
	local(@tmp_arr, $v_msg, $t_path, $t_dir);

	if (!-e $p_workfile) {
		return("add file [$p_workfile] is not found!");
	}
	$p_workfile =~ s/\/\//\//g;
	$v_msg = `$cmd_svn info $p_workfile`;
	if (index($v_msg, 'URL:')>0) {
		return('');
	}
	
	@tmp_arr = split(/\//, $p_workfile);
	$t_path = '';
	foreach $t_dir (@tmp_arr) {
		if ($t_dir eq '') {
			next;
		}
		$t_path .= '/'.$t_dir;
		if (length($t_path) < length($p_svnworkpath)) {
			next;
		}
		$v_msg = `$cmd_svn info $t_path`;
		if (index($v_msg, 'URL:')>0) {
			next;
		}
		$v_msg = `$cmd_svn add $t_path`;
		if (substr($v_msg,1,2) ne 'A ') {
			return($v_msg);
		}
	}
	return('');
}

sub runsvn {
	local($p_file) = @_;
	local($v_workfile, $v_filestatus, $cmd_ciresult, $v_msg, $t_msg);

	$v_workfile = $p_svnworkpath.$p_file;
	$v_workfile =~ s/\/\//\//g;
	if (-e $v_workfile) {
		$v_msg = `$cmd_rm $v_workfile`;
		if ($v_msg ne '') {
			return($v_msg);
		}
	}
	
	$t_msg = runlink($p_file, $v_workfile);
	if ($t_msg ne '') {
		$v_svnadderr++;
		return($t_msg);
	}
	$t_msg = svnadd($v_workfile);
	if ($t_msg ne '') {
		$v_svnadderr++;
		return($t_msg);
	}
	$v_svnadd++;
	$v_msg = "Svn Add OK [$v_workfile]\n";
	return($v_msg);
}	
