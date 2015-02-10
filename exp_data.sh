#!/bin/sh
# Setting Env
export LANG=C
export exppgsqlpath=/data/db_dump/pgsql_data
export logfile=/root/logs/`date +%Y%m`_exp_data.log

#
# Export SVN 
#
/bin/date +"%Y-%m-%d %H:%M:%S" >> $logfile
echo "Export SVN Begin..." >> $logfile
echo "===================" >> $logfile
/usr/bin/perl /root/exp_svn.pl  >> $logfile
echo "===================" >> $logfile
echo "Export SVN End" >> $logfile
/bin/date +"%Y-%m-%d %H:%M:%S" >> $logfile
#
# Export PostgreSQL
#
#echo "Export PostgreSQL Begin..." >> $logfile
#echo "==========================" >> $logfile
#/usr/bin/perl /root/exp_pgsql.pl  >> $logfile
#echo "==========================" >> $logfile
#echo "Export PostgreSQL End" >> $logfile
#/bin/date +"%Y-%m-%d %H:%M:%S" >> $logfile
