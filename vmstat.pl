#!/usr/bin/perl
# 12:47 2016/3/22
# Jonathan Tsai
# vmstat insert into influxdb
#
# 1.01 增加 node4, node5, 改成隨機等待 1-10 秒繼續執行
# 1.02 增加寫入異常 node 會 retry 另一台 node

# Create DB
#curl -G http://infxnode3:8086/query --data-urlencode "q=CREATE DATABASE sysmon01"
$db_name='sysmon01';
$table_name='vmstat_log';
@db_server_arr=('infxnode1', 'infxnode2', 'infxnode3', 'infxnode4', 'infxnode5');
$db_port='8086';

#influxdb1
$hostname=`/bin/hostname`;
$hostname =~ s/\n|\r//g;

while(1) {
	write_data();
	$idx=int(rand(10))+1;
	sleep($idx);
}
exit;



sub write_data {

	#procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
	# r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
	# 1  0      0 689204  23528 178460    0    0    16     9  105  246  0  0 99  0  0
	# 1 0 0 689204 23528 178460 0 0 16 9 105 246 0 0 99 0 0
	@vmstat_arr=split(' ', `/usr/bin/vmstat | tail -1 | awk '{print \$1,\$2,\$3,\$4,\$5,\$6,\$7,\$8,\$9,\$10,\$11,\$12,\$13,\$14,\$15,\$16,\$17}'`);
	@type_arr=('procs=r', 'procs=b', 'memory=swpd', 'memory=free', 'memory=buff', 'memory=cache', 'swap=si', 'swap=so', 'io=bi', 'io=bo', 'system=in', 'system=cs', 'cpu=us', 'cpu=sy', 'cpu=id', 'cpu=wa', 'cpu=st');

	# Insert Data
	#curl -i -XPOST 'http://infxnode3:8086/write?db=sysmon01' --data-binary 'vmstat_log,host=influxdb1,procs=r value=1'
	#curl -i -XPOST 'http://infxnode3:8086/write?db=sysmon01' --data-binary 'vmstat_log,host=influxdb1,procs=b value=0'
	#curl -i -XPOST 'http://infxnode3:8086/write?db=sysmon01' --data-binary 'vmstat_log,host=influxdb1,memory=swpd value=0'
	#curl -i -XPOST 'http://infxnode3:8086/write?db=sysmon01' --data-binary 'vmstat_log,host=influxdb1,memory=free value=689204'

	$msg='';
	while ($msg eq '') {
		# Get DB Server
		$db_server_num=@db_server_arr;
		$idx=int(rand($db_server_num));
		$db_server=$db_server_arr[$idx];

		# Inser Data
		$cmd_temp = "curl -s -i -XPOST 'http://%%db_server%%:%%db_port%%/write?db=%%db_name%%' --data-binary '%%table_name%%,host=%%hostname%%,%%type%% value=%%value%%'";
		$cmd_temp =~ s/%%db_server%%/$db_server/;
		$cmd_temp =~ s/%%db_port%%/$db_port/;
		$cmd_temp =~ s/%%db_name%%/$db_name/;
		$cmd_temp =~ s/%%table_name%%/$table_name/;
		$cmd_temp =~ s/%%hostname%%/$hostname/;

		$idx=0;
		$msg='';
		foreach $value (@vmstat_arr) {
			$type=$type_arr[$idx];
			$cmd_loop_temp = $cmd_temp;
			$cmd_loop_temp =~ s/%%type%%/$type/;
			$cmd_loop_temp =~ s/%%value%%/$value/;
			#print("[$cmd_loop_temp]\n");
			$msg .= `$cmd_loop_temp`;
			$idx++;
		}
		if ($msg eq '') {
			print("db_server:[$db_server]\n");
		}
		else {
			#print("[$msg]\n");
		}
	}
return;
}