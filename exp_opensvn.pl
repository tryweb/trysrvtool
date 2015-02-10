#!/usr/bin/perl
#
# 00:10 2008/03/02
# Jonathan Tsai
# Ver 1.02
#
# �۰ʶץX svn �M�ץؿ����
#
# 1.00 (2006/5/15) �Ĥ@���ҥ�
# 1.01 (2007/3/14) ��� SVN �ؿ�
# 1.02 (2008/3/1) �W�[�ץX��� gzip ���Y

$prgname = substr($0, rindex($0,"/")+1);
$ver = "1.02 (2008/3/1)";
$svnpath = "/data/opensvn";
$expsvnpath = "/data/db_dump/svn_data";
$skipdirlist = ".;..;"; # �ư��ץX�� svn �ؿ��M�� (abc;xxx;)

print("$prgname Ver $ver\n");
# �إ� svnpath ���Ҧ��M�ץؿ��M��
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
