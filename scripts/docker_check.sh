#!/bin/bash
function docker_check {
#check for devcontainer docker assumes default docker network
defaultDocker="127.17.0.1"
route=$(ip route show default | awk '{ print $3}')
ip route show default | fgrep -q 'default via 172.17.0.1'
if [ $? -eq 0 ]; then
   echo "matches docker address $route, $defaultDocker"
   export VAULT_ADDR="http://${route}:8200"
else
   echo "doesn't match docker $route, $defaultDocker"
   export VAULT_ADDR=${vaultHost}
fi
}
