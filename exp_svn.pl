#!/usr/bin/perl
#
# 11:08 2009/3/3
# Jonathan Tsai
# Ver 1.03
#
# 自動匯出 svn 專案目錄資料
#
# 1.00 (2006/5/15) 第一版啟用
# 1.01 (2007/3/14) 更改 SVN 目錄
# 1.02 (2008/3/1) 增加匯出後用 gzip 壓縮
# 1.03 (2009/3/3) 增加匯出前先 verify 並比對之前匯出的版本編號決定是否需要匯出

$prgname = substr($0, rindex($0,"/")+1);
$ver = "1.03 (2009/3/3)";
$svnpath = "/var/www/svn";
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
		print("$nowmsg Verify [$svndir]...");
		$max=0;
		foreach $line (split(/\n/, `/usr/bin/svnadmin verify $svnpath/$svndir 2>&1`)) {
			($a1, $a2, $a3, $svn_no) = split(/ /,$line);
			$svn_no =~ s/\.//g;
			$max = ($svn_no>$max)?$svn_no:$max;
		}
		print("$max\n");
		if (chkSVNVer($expsvnpath, $svndir, $max)) {
			print("$nowmsg Exporting [$svndir]...");
			`/usr/bin/svnadmin dump -q $svnpath/$svndir | gzip -9> $expsvnpath/$svndir.svn.gz`;
			`echo -n $max > $expsvnpath/$svndir.verno`;
			print("OK!\n");
		}
		else {
			print("$nowmsg Already Exported\n");
		}
	}
}

sub chkSVNVer {
	local($p_expdir, $p_svnname, $p_svn_no) = @_;
	local($v_now_no);
	
	if (!-e $p_expdir.'/'.$p_svnname.'.verno') {
		return(1);
	}
	$v_now_no = `cat $p_expdir/$p_svnname.verno`;
	$v_now_no =~ s/\n|\r| |\t//g;
	if ($p_svn_no>$v_now_no) {
		print("SVN Reversion :$v_now_no -> $p_svn_no\n");
	}
	
	return($p_svn_no>$v_now_no);
}