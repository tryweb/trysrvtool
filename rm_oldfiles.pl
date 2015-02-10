#!/usr/bin/perl
#
# 19:25 2008/12/29
# Jonathan Tsai
# Ver 1.11
#
# delete old files before keep_days
# Usage : rm_oldfiles.pl <keep_days> <dir> <mode> <force>
#  * <dir> : default is current dir
#  * <mode> : file/dir/both  (file:(default) only delete old files , dir: only delete old dirs, both delete both old files and dirs)
#  * Only give <force> to delete automatically; ortherwise, print the delete command lists to stdout
#
# 1.00 (2008/8/26) First Version Release
#
use Fcntl ':mode';

$prgname = substr($0, rindex($0,"/")+1);
$ver = "1.11 (2008/12/29)";
$g_skipdirlist = ".;..;";
$p_keep_days = defined($ARGV[0])?$ARGV[0]:-1;
$p_dir = defined($ARGV[1])?$ARGV[1]:".";
$p_dir = (length($p_dir)>1 && substr($p_dir,-1) eq "/")?substr($p_dir,0,length($p_dir)-1):$p_dir;
$p_mode = defined($ARGV[2])?$ARGV[2]:"file";
$p_mode = ($p_mode ne "file" && $p_mode ne "dir" && $p_mode ne "both")?"file":$p_mode;
$p_force = defined($ARGV[3] && $ARGV[3] eq "force")?1:0;

print("# $prgname Ver $ver \n#	keep_days:$p_keep_days\n#	dir:$p_dir\n#	mode:$p_mode\n#	force:$p_force\n");
if ($p_keep_days<0) {
	print("Usage:\n	$prgname <keep_days> (<dir> <mode:file/dir/both> <force>)\nExp.\n");
	print("	$prgname 10 <-- Keep 10 days files for current dir\n");
	print("	$prgname 7 /var/log <-- Keep 7 days files for /var/log\n");
	print("	$prgname 7 /var/log file force <-- Keep 7 days files for /var/log and delete old files automatically\n");
	print("	$prgname 7 /var/log both force <-- Keep 7 days files and dirs for /var/log and delete old files and dirs automatically\n");
	exit;
}

$v_oldfile_time = time - $p_keep_days * 60 * 60 * 24;
procDir($p_dir, $v_oldfile_time, $p_mode, $p_force);

sub procDir {
	local($p_dir, $p_oldfile_time, $p_mode, $p_force) =@_;
	local(@arr_dirlist, $v_file, $t_dir_file, $t_dev,$t_ino,$t_mode,$t_nlink,$t_uid,$t_gid,$t_rdev,$t_size,$t_atime,$t_mtime,$t_ctime,$t_blksize,$t_blocks, $t_isdir);
	
	opendir(DIR, $p_dir) || die "can't opendir $p_dir: $!";
	@arr_dirlist = readdir(DIR);
	close(DIR);

	foreach $v_file (@arr_dirlist) {
		if (index($g_skipdirlist, $v_file.";")<0) {
			$t_dir_file = $p_dir."/".$v_file;
			# (0.$dev,1.$ino,2.$mode,3.$nlink,4.$uid,5.$gid,6.$rdev,7.$size,8.$atime,9.$mtime,10.$ctime,11.$blksize,12.$blocks) = stat($filename);
			($t_dev,$t_ino,$t_mode,$t_nlink,$t_uid,$t_gid,$t_rdev,$t_size,$t_atime,$t_mtime,$t_ctime,$t_blksize,$t_blocks) = stat($t_dir_file);
			$t_isdir = S_ISDIR($t_mode);
			if ($t_isdir) {
				procDir($t_dir_file, $p_oldfile_time, $p_mode, $p_force);
			}
			if ($t_mtime < $p_oldfile_time) {
				if ((!$t_isdir && ($p_mode eq "file" || $p_mode eq "both")) || ($t_isdir && ($p_mode eq "dir" || $p_mode eq "both"))) {
					try_delete($t_dir_file, $t_isdir, $p_force);
				}
			}
		}
	}
	
	return;
}

# $p_type : FALSE. file TRUE. dir
# $p_mode : 0. return cmd script 1. run cmd script and return result
sub try_delete {
	local ($p_file, $p_type, $p_mode) = @_;
	local ($v_msg, $v_rm_arg);

	$v_rm_arg = ($p_type)?"-rf":"-f";
	if ($p_mode==1) {
		# run cmd script
		print("Delete [$p_file]\n");
		`rm $v_rm_arg '$p_file'`;
	}
	else {
		# return cmd script
		print("rm $v_rm_arg '$p_file'\n");
	}
	
	return;
}
