#!/usr/bin/perl
#
# 00:10 2008/03/02
# Jonathan Tsai
# Ver 1.02
#
# 自動匯出 svn 專案目錄資料
#
# 1.00 (2006/5/15) 第一版啟用
# 1.01 (2007/3/14) 更改 SVN 目錄
# 1.02 (2008/3/1) 增加匯出後用 gzip 壓縮

$prgname = substr($0, rindex($0,"/")+1);
$ver = "1.02 (2008/3/1)";
$svnpath = "/data/opensvn";
$expsvnpath = "/data/db_dump/svn_data";
$skipdirlist = ".;..;"; # 排除匯出的 svn 目錄清單 (abc;xxx;)

print("$prgname Ver $ver\n");
# 建立 svnpath 內所有專案目錄清單
opendir(DIR, $svnpath) || die "can't opendir $svnpath: $!";
@svndirlist = readdir(DIR);
close(DIR);
foreach $svndir (@svndirlist) {
	if (index($skipdirlist, $svndir.";")<0) {
		$nowmsg = `/bin/date +"%Y-%m-%d %H:%M:%S"`;
		$nowmsg =~ s/\n|\r//;
		print("$nowmsg Exporting [$svndir]...\n");
		`/usr/bin/svnadmin dump -q $svnpath/$svndir | gzip -9> $expsvnpath/$svndir.svn.gz`;
	}
}
