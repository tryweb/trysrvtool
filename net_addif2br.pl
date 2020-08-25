#!/usr/bin/perl
#
# 自動檢查 virbr0 bridge 啟動後將 p3p1 網卡加入 bridge 內

$g_br='virbr0';
$g_if='p3p1';

$g_sw=1;

while ($g_sw) {
		$t_msg1 = `ifconfig $g_br`;
		$t_msg2 = `ifconfig $g_if`;
		$g_sw = (index($t_msg1, 'Link')>0 && index($t_msg2, 'Link')>0)?0:1;

		if (!$g_sw) {
				print("Add IF [$g_if] into Bridge [$g_br] ..");
				$t_msg = `brctl addif $g_br $g_if`;
				print("[$t_msg]\n");
				exit;
		}
		sleep(1);
		print("Wait...\n");
}
