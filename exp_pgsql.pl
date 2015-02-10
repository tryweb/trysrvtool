#!/usr/bin/perl
#
# 15:01 2008/3/21
# Jonathan Tsai
# Ver 1.01
#
# �۰ʶץX PostgreSQL DB ���
#
# 1.00 (2006/5/15) �Ĥ@���ҥ�
# 1.01 (2008/3/21) �W�[�w�q�ץX�Ҧ��Ѽ� schema:�u�ץX schema, data:�u�ץX data, both(default):��̳��ץX

$g_prgname = substr($0, rindex($0,"/")+1);
$g_ver = "1.01 (2008/3/21)";
$g_exppgsqlpath = "/data/db_dump/pgsql_data";
$g_skipdblist = "template0;template1;"; # �ư��ץX�� DB �M�� (abc;xxx;)

# ��J�Ѽ�  schema:�u�ץX schema, data:�u�ץX data, both(default):��̳��ץX
$p_mode = !defined($ARGV[0])?"both":lc($ARGV[0]);
$p_mode = ($p_mode ne "schema" && $p_mode ne "data" && $p_mode ne "both")?"both":$p_mode;

print("$g_prgname Ver $g_ver\n");
# �إ� PostgreSQL ���Ҧ� DB �M��
$cmd_tmp = `/usr/bin/psql --list -t`;
@dblist = split(/\n/,$cmd_tmp);
foreach $t_dbline (@dblist) {
	($v_dbname, $v_owner, $v_encoding) = split(/\|/, $t_dbline);
	$v_dbname =~ s/ //g;
	if (index($g_skipdblist, $v_dbname.";")<0) {
		$cmd_nowmsg = `/bin/date +"%Y-%m-%d %H:%M:%S"`;
		$cmd_nowmsg =~ s/\n|\r//;
		if ($p_mode eq "both" || $p_mode eq "schema") {
			print("$cmd_nowmsg Exporting [$v_dbname] schema...\n");
			`/usr/bin/pg_dump --schema-only $v_dbname > $g_exppgsqlpath/$v_dbname\_schema.sql`;
		}
		if ($p_mode eq "both" || $p_mode eq "data") {
			print("$cmd_nowmsg Exporting [$v_dbname] data...\n");
			`/usr/bin/pg_dump --data-only $v_dbname > $g_exppgsqlpath/$v_dbname\_data.sql`;
		}
	}
}
