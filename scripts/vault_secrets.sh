function vault_secrets {
#vault_secrets [vaultHost] [vaultToken] [secret]
vaultHost=${1:-"http://localhost:8200"}
vaultToken=${2:-"root"}
secretName=${3:-"nginx"}
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
export VAULT_TOKEN=$(echo "${vaultToken}")
#
function kvVersion {
    curl -s \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request GET \
    $VAULT_ADDR/v1/sys/mounts | jq keys | grep 'secret/' > /dev/null 2>&1
    if [ $? == 0 ]; then
        version=$(curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request GET $VAULT_ADDR/v1/sys/mounts | jq -r '.["secret/"].options.version')
        echo $version
    else
        echo "type yes to enable the v2 secrets api"
        read answer
        if [ $answer == "yes" ]; then
            curl --header "X-Vault-Token: $VAULT_TOKEN" \
            --request POST \
            --data '{ "type": "kv-v2" }' \
            $VAULT_ADDR/v1/sys/mounts/secret
            echo "v2 enabled at /secret"
        else
            echo "please enable v2 to continue"
        fi
    fi

}
#payload default cert/key
nginx=$(cat -<<EOF
{
  "data": {
    "nginxCert": "$(echo -n "$(<./certs/nginx-repo.crt)" | base64 -w 0)",
    "nginxKey": "$(echo -n "$(<./certs/nginx-repo.key)" | base64 -w 0)",
    "defaultCert": "$(echo -n "$(<./certs/nginx-default.crt)" | base64 -w 0)",
    "defaultKey": "$(echo -n "$(<./certs/nginx-default.key)" | base64 -w 0)"
  }
}
EOF
)

# vault store data
kvApiVersion=$(kvVersion)
echo "kv version: $kvApiVersion"
if [ $kvApiVersion == "2" ]; then
    curl -s \
        --header "X-Vault-Token: $VAULT_TOKEN" \
        --request POST \
        --data "$nginx" \
        $VAULT_ADDR/v1/secret/data/$secretName
else
    echo "kv api version not v2"
    echo "quitting..."
fi
}
