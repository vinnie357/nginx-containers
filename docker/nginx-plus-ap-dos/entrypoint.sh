#!/usr/bin/env bash
# turn on bash's job control
set -m
# set log path
LOGPATH=/var/log/adm/admd.log

mkdir -p /shared/cores && chmod 755 /shared/cores

/usr/bin/adminstall --daemons 1 --memory 100 > ${LOGPATH} 2>&1
/usr/sbin/nginx &
/usr/bin/admd -d --standalone > ${LOGPATH} 2>&1 &
# start agent
/usr/sbin/nginx-agent
# now we bring the primary process back into the foreground
# and leave it there
fg %1
