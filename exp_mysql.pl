#!/usr/bin/perl
#
# 19:53 2014/4/20
# Jonathan Tsai
# Ver 1.11
#
# 自動匯出 MySQL DB 資料
# /usr/bin/mysqldump -u root -p'g2BB!everplast#' --database everstar --no-data  > db_schema.sql
# /usr/bin/mysqldump -u root -p'g2BB!everplast#' --all-database --no-data  > schema.sql
#
# 1.00 (2008/3/21) 第一版啟用，匯出模式參數 schema:只匯出 schema, data:只匯出 data, both(default):兩者都匯出

$g_prgname = substr($0, rindex($0,"/")+1);
$g_ver = "1.11 (2014/4/20)";
$p_config = !defined($ARGV[0])?"/opt/trysrvtool/exp_mysql.conf":$ARGV[0];

# 預設外部命令
$cmd_gzip = '/bin/gzip';
$cmd_date = '/bin/date';
$cmd_mysqldump = '/usr/bin/mysqldump';

# 預設參數
$g_expmysqlpath = "/mysqldump";
$g_backupmode = 'both'; #'schema'
$g_backupdblist = ''; #'mysql,xxx,yyy'
$g_user = 'root';
$g_password = 'passwd_1234';
$g_dbhost = '127.0.0.1';
$g_isgzip = 1; # using gzip compress
$g_fileformat = 'database_'.`/bin/date '+%H'`.'.sql';


if (-e $p_config) {
	require($p_config);
}

print("$g_prgname Ver $g_ver\n");
print("	Backup Mode: $g_backupmode\n");

$v_nodata_arg = ($g_backupmode eq 'schema')?'--no-data':'';
$v_gzip_arg = '';
if ($g_isgzip==1) {
	$g_fileformat .= '.gz';
	$v_gzip_arg = '| '.$cmd_gzip;
}
$g_fileformat =~ s/\n|\r//g;

if ($g_backupdblist eq '') {
	print("	Start Backup All Databases to $g_fileformat\n");
	$t_msg = `$cmd_mysqldump -u $g_user -p'$g_password' -h $g_dbhost --all-database $v_nodata_arg $v_gzip_arg > $g_expmysqlpath/$g_fileformat`;
	if ($t_msg ne '') {
		print($t_msg);
	}
}
else {
	@arr_dblist = split(/,/,$g_backupdblist);
	foreach $v_dbname (@arr_dblist) {
		$v_dbname =~ s/ //g;
		$v_fileformat = $v_dbname.'_'.$g_fileformat;
		print("	Start Backup $v_dbname Database to $v_fileformat\n");
		$t_msg = `$cmd_mysqldump -u $g_user -p'$g_password' -h $g_dbhost --database $v_dbname $v_nodata_arg $v_gzip_arg > $g_expmysqlpath/$v_fileformat`;
		if ($t_msg ne '') {
			print($t_msg);
		}
		print("	Finish Backup $v_dbname Database\n");
	}
}
print("	Finish Backup All Databases\n");
