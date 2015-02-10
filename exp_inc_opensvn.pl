#!/usr/bin/perl
#
# 23:58 2008/03/01
# Jonathan Tsai
# Ver 1.00
#
# 自動匯出 svn 專案目錄差異資料
#
# 1.00 (2008/3/1) 第一版啟用

$prgname = substr($0, rindex($0,"/")+1);
$ver = "1.00 (2008/3/1)";
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
		$verno=`/usr/bin/svnlook youngest $svnpath/$svndir`;
		for ($r=1;$r<$verno;$r++) {
			if (!-f "$expsvnpath/$svndir-$r.gz") {
				`/usr/bin/svnadmin dump -q $svnpath/$svndir -r $r --incremental | gzip -9> $expsvnpath/$svndir-$r.gz`;
			}	
		}
	}
}
