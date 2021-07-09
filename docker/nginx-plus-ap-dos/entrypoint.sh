#!/usr/bin/env bash

LOGPATH=/var/log/adm/admd.log

mkdir -p /shared/cores && chmod 755 /shared/cores

/usr/bin/adminstall --daemons 1 --memory 100 > ${LOGPATH} 2>&1
/usr/sbin/nginx &
/usr/bin/admd -d --standalone > ${LOGPATH} 2>&1 &
