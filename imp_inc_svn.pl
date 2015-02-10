#!/usr/bin/perl
#
# 22:34 2010/10/6
# Jonathan Tsai
# Ver 1.00
#
# 自動匯入 svn 專案目錄差異資料
# imp_inc_svn.pl project /inc_svn_path/
#
# 1.00 (2010/10/6) 第一版啟用

$prgname = substr($0, rindex($0,"/")+1);
$ver = "1.00 (2010/10/6)";
$svnpath = "/var/www/svn";
$incsvnpath = "/backup/db_dump/svn_data";

print("$prgname Ver $ver\n");

if (!defined($ARGV[0])) {
	print("Usage: imp_inc_svn.pl project [/inc_svn_path/]\n");
	exit;
}
$g_prjname=$ARGV[0];
if (-f "$g_prjname/format") {
	$prjsvnpath=$g_prjname;
}
elsif (-f "$svnpath/$g_prjname/format") {
	$prjsvnpath=$svnpath.'/'.$g_prjname;
}
else {
	print("project path [$g_prjname] is not exist!\n");
	exit;
}
$prjverno=`/usr/bin/svnlook youngest $prjsvnpath 2>&1`;

$incsvnpath=(defined($ARGV[1]))?$ARGV[1]:$incsvnpath;
if (!-e $incsvnpath) {
	print("inc_svn_path [$incsvnpath] is not exist!");
	exit;
}

$prjverno++;
while(-f "$incsvnpath/$g_prjname-$prjverno.gz") {
	#print("proc:[$prjverno]..\n");
	if (-f "/tmp/$g_prjname-$prjverno") {
		$msg=`rm /tmp/$g_prjname-$prjverno 2>&1`;
		if ($msg ne '') {
			print("rm:[$msg]\n");
		}
	}	
	$msg=`cp $incsvnpath/$g_prjname-$prjverno.gz /tmp/;/bin/gunzip /tmp/$g_prjname-$prjverno.gz 2>&1`;
	if ($msg ne '') {
		print("cp_gunzip:[$msg]\n");
	}
	$msg=`cat /tmp/$g_prjname-$prjverno | svnadmin load $prjsvnpath 2>&1`;
	print("$msg\n");
	$msg=`rm /tmp/$g_prjname-$prjverno 2>&1`;
	if ($msg ne '') {
		print("rm:[$msg]\n");
	}
	$prjverno++;
}
