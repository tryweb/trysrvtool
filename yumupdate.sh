#!/bin/bash
#
# Source - http://www.cyberciti.biz/faq/fedora-automatic-update-retrieval-installation-with-cron/
#
# -R 120 : Sets the maximum amount of time yum will wait before performing a command
# -e 0 : Sets the error level to 0 (range 0 - 10). 0 means print only critical errors about which you must be told.
# -d 0 : Sets the debugging level to 0 - turns up or down the amount of things that are printed. (range: 0 - 10).
# -y : Assume yes; assume that the answer to any question which would be asked is yes.
#
YUM=/usr/bin/yum
$YUM -y -R 120 -d 0 -e 0 update yum
$YUM -y -R 10 -e 0 -d 0 update