#!/usr/bin/env bash
# turn on bash's job control
set -m
# start app protect daemon
/bin/su -s /bin/sh -c '/opt/app_protect/bin/bd_agent &' nginx &
# configure app protect
/bin/su -s /bin/sh -c "/usr/share/ts/bin/bd-socket-plugin tmm_count 4 proc_cpuinfo_cpu_mhz 2000000 total_xml_memory 307200000 total_umu_max_size 3129344 sys_max_account_id 1024 no_static_config 2>&1 >> /var/log/app_protect/bd-socket-plugin.log &" nginx
# start nginx
/usr/sbin/nginx -g 'daemon off;' &
# start agent
# wait for app protect to start then start agent
# watch /var/log/access.log for 'APP_PROTECT { "event": "configuration_load_success"' then start agent
/bin/sleep 15 && /usr/sbin/nginx-agent
# now we bring the primary process back into the foreground
# and leave it there
fg %1
