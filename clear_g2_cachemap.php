<?php
require_once('clear_g2_cachemap.conf.php');

# Connect to Database
$s_dbh = mysql_connect($g_dbhost, $g_dbuser, $g_dbpasswd);

$sqlstr = 'truncate table g2_CacheMap;';
echo date("Y-d-m H:i:s")." Start..\n";
foreach ($g_dbname_arr as $v_dbname) {
	echo date("Y-d-m H:i:s")." truncate [$v_dbname]";
	$s_res = mysql_db_query($v_dbname, $sqlstr, $s_dbh);
	$v_result= (!$s_res)?'Error!':'OK!';
	echo " $v_result\n";
}
echo date("Y-d-m H:i:s")." End..\n";

mysql_close($s_dbh);
?>
