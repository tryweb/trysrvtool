#!/usr/bin/perl
#
# 16:32 2010/10/7
# Jonathan Tsai
# Ver 1.12
#
# 自動將 svn 訊息寫入 mantis 紀錄內
#
# 參考 http://www.ichiayi.com/trywiki/tech/svnmantis 的說明方式
# 本 script 需配合:
#  1. /var/www/svn/xxxrepos/hooks/post-commit 一起使用
#  2.apache user 可使用 ssh 免密碼登入 Mantis 主機 <- SVN 主機與 Mantis 主機不同時需要
#
# 1.00 (2007/3/26) 第一版啟用
# 1.01 (2007/3/26) 增加 commit 後自動整合的說明
# 1.10 (2007/6/22) 增加 遠端登入 Mantis 主機功能設定
# 1.11 (2008/4/30) 增加第三個參數，當成 sshcmd 的外部設定(避免與 Source 混在一起)
# 1.12 (2010/10/7) Mantis 1.3.x 將 mantis/core/checkin.php 改移到 mantis/scripts/checkin.php
#

$prgname = substr($0, rindex($0,"/")+1);
$ver = "1.12 (2010/10/7)";

# 讀取參數資料
$REPOS=$ARGV[0];
$REV=$ARGV[1];
# $sshcmd 設為空字串表示 SVN 與 Mantis 安裝在相同主機
$sshcmd = defined($ARGV[2])?"/usr/bin/ssh ".$ARGV[2]:"";
# 第三個參數為由 svn 主機免密碼登入 Mantis 主機的 ssh 命令參數 Exp. jonathan@10.10.10.96 -> $sshcmd = "/usr/bin/ssh jonathan\@10.10.10.96";

# 定義外部指令
$svnlook = "export LANG=zh_TW.UTF-8;/usr/bin/svnlook";
$phpcmd = "/usr/bin/php";
$checkincmd = "/var/www/html/mantis/core/checkin.php";
if ($sshcmd eq '') {
	if (!-f $checkincmd) {
		$checkincmd = "/var/www/html/mantis/scripts/checkin.php";
		if (!-f $checkincmd) {
			print("Local Mantis checkin.php is not exist!\n");
			exit;
		}
	}
}
else {
	$msg=`$sshcmd file $checkincmd`;
	if (index($msg, 'ERROR')>0) {
		$checkincmd = "/var/www/html/mantis/scripts/checkin.php";
		$msg=`$sshcmd file $checkincmd`;
		if (index($msg, 'ERROR')>0) {
			print("Remote Mantis checkin.php is not exist!\n");
			exit;
		}	
	}
}

# 取得 svn 相關資訊
$auth=`$svnlook author -r $REV $REPOS`;
$dt=`$svnlook date -r $REV $REPOS`;
$changed=`$svnlook changed -r $REV $REPOS`;
$log=`$svnlook log -r $REV $REPOS`;
$msg="Changeset [".$REV."] by $auth\n$dt\n$log\n$changed";

# 傳送至 mantis
if (length($sshcmd)>0) {
	`$sshcmd $phpcmd -q $checkincmd <<< "$msg"`;
}
else {
	`$phpcmd -q $checkincmd <<< "$msg"`;
}
