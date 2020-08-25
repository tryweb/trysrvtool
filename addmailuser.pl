#!/usr/bin/perl -w
# 
# Add Mail User script
# Ver 1.01
# 11:09 2015/5/12
# Jonathan Tsai
#
# 1.00(2005/8/18) 第一版上線
# 1.01(2015/5/12) 增加檢查建立 INBOX 目錄
#
# SVN Info - $Id: addmailuser.pl 294 2016-11-06 05:15:57Z jonathan $
#

my $sysver = "1.01(2015/5/12)";
print("AddMailUser Script Ver $sysver \n");

# Check Mail User Group
my $cmdline = "/bin/cat /etc/group | /bin/grep mailuser";
my $cmdresult = `$cmdline`;
if (index($cmdresult,"mailuser:x")<0) {
	print("Greate mailuser group...");
	$cmdline = "/usr/sbin/groupadd mailuser";
	$cmdresult = `$cmdline`;
	if (length($cmdresult)>0) {
		print("Add Group Error:[$cmdresult]\n");
		exit;
	}
}

my $uid = $ARGV[0];
my $realname = $ARGV[1];
my $userid = $ARGV[2];

if (length($uid)==0 || length($realname)==0 || length($userid)==0) {
	print("	Syntex : $0 uid \"realname\" userid\n");
	print("		Example :\n			$0 601 \"Try Web\" tryweb\n");
	exit;
}

if ($uid <= 500 || $uid > 1000) {
	print("	uid must between 500 to 1000\n");
	exit;
}

$cmdline = "/usr/sbin/useradd -g mailuser -s /bin/false -u $uid -c \"$realname\" $userid";
$cmdresult = `$cmdline`;

$cmdline = "/bin/mkdir -p ~$userid/mail/.imap/INBOX";
$cmdresult = `$cmdline`;
$cmdline = "/bin/chown -R $userid:mailuser ~$userid/mail";
$cmdresult = `$cmdline`;

$cmdline = "/usr/bin/tail /etc/passwd | /bin/grep $userid";
$cmdresult = `$cmdline`;
if (length($cmdresult)>0) {
	print("Add Mail User [$userid] OK!\n");
}

