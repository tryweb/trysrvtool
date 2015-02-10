#!/bin/sh
# update trysrvtool script
export LANG=C
cd /opt/trysrvtool
svn update
chmod a+x -R /opt/trysrvtool