function build_nginx {
# build_nginx [registry] [type] [tag] [secret]
# build_nginx "" nginx-plus-ap "" nginx-plus
# default tag is latest
registry=${1:-"dockerlocal"}
type=${2:-"nginx-plus"}
tag=${3:-"latest"}
secretName=${4:-"none"}
dir=${PWD}
function docker_build {
  #docker_build ${registry}/${type}:${tag}
  IMAGE=$1
  docker build -t $IMAGE .
  if [[ "${registry}" == "dockerlocal" ]]; then
    echo "local not pushing"
  else
    echo "pushing $IMAGE"
    read -p "Press enter to continue"
    docker push $IMAGE
  fi
}
needCerts="nginx-plus nginx-plus-ap nginx-plus-ap-converter nginx-plus-ap-dos"
# manage secrets
if [ "${secretName}" = "none" ] && [[ " ${needCerts[@]} " =~ " ${type} " ]]; then
  echo "using default secret"
  if [ -f "./certs/nginx-repo.crt" ] && [ -f "./certs/nginx-repo.key" ]; then
      echo "found default certs"
  else
      # create default cert
      echo "create default kic certs"
      new_cert
  fi
  echo "ingest secrets"
  echo -n "Enter your vault hostname and press [ENTER]: "
  echo ""
  echo -n "default hostname is: http://localhost:8200 :"
  read vaultHost
  echo -n "Enter your vault token and press [ENTER]: "
  echo ""
  echo -n "default token is: root :"
  read -s vaultToken
  echo ""
  echo -n "Enter your secret name and press [ENTER]: "
  read secret
  # store secrets
  #check for devcontainer docker assumes default docker network
  if [[ "${vaultHost}" == "http://localhost:8200" ]]; then
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
    else
      # remote vault
      export VAULT_ADDR=${vaultHost}
  fi
  vault_secrets $vaultHost $vaultToken $secret
  VAULT_TOKEN=${vaultToken:-"root"}
else
  if [[ "${type}" == "nginx" ]]; then
    echo "oss skipping secrets"
  else
    echo "found secret $secretName"
    echo -n "Enter your vault hostname and press [ENTER]: "
    echo ""
    echo -n "default hostname is: http://localhost:8200 :"
    read vaultHost
    echo -n "Enter your vault token and press [ENTER]: "
    echo ""
    echo -n "default token is: root :"
    read -s vaultToken
    #check for devcontainer docker assumes default docker network
    if [[ "${vaultHost}" == "http://localhost:8200" ]]; then
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
      else
        # remote vault
        export VAULT_ADDR=${vaultHost}
    fi
    VAULT_TOKEN=${vaultToken:-"root"}
  fi
fi
echo "build $type container"
# get secrets
# https://stackoverflow.com/questions/3685970/check-if-a-bash-array-contains-a-value
if [[ " ${needCerts[@]} " =~ " ${type} " ]]; then
secretData=$(
curl -s \
--header "X-Vault-Token: $VAULT_TOKEN" \
--request GET \
$VAULT_ADDR/v1/secret/data/$secretName
)
echo "writing secrets"
cat << EOF > docker/${type}/nginx-repo.crt
$(echo $secretData | jq -r .data.data.nginxCert | base64 -d)
EOF
# key
cat << EOF > docker/${type}/nginx-repo.key
$(echo $secretData | jq -r .data.data.nginxKey | base64 -d)
EOF

fi
# local builds
if [[ "${registry}" == "dockerlocal" ]]; then
  registryPath=""
else
  registryPath="${registry}/"
fi
if [[ "${type}" == "nginx" ]]; then
  echo "==== building $type:$tag ===="
  ## make nginx-oss
  cd docker/$type
  docker_build ${registryPath}${type}:${tag}
fi

if [[ "${type}" == "nginx-plus" ]]; then
  echo "==== building $type:$tag ===="
  ## make nginx-plus
  cd docker/$type
  docker_build ${registryPath}${type}:${tag}
  rm nginx-repo.crt nginx-repo.key
fi

if [[ "${type}" == "nginx-plus-ap" ]]; then
  echo "==== building $type:$tag ===="
  ## make nginx-plus-ap
  cd docker/$type
  docker_build ${registryPath}${type}:${tag}
  rm nginx-repo.crt nginx-repo.key
fi
if [[ "${type}" == "nginx-plus-ap-converter" ]]; then
  echo "==== building $type:$tag ===="
  ## make nginx-plus-ap-converter
  cd docker/$type
  docker_build ${registryPath}${type}:${tag}
  rm nginx-repo.crt nginx-repo.key
fi
if [[ "${type}" == "nginx-plus-ap-dos" ]]; then
  echo "==== building $type:$tag ===="
  ## make nginx-plus-ap-dos
  cd docker/$type
  docker_build ${registryPath}${type}:${tag}
  rm nginx-repo.crt nginx-repo.key
fi
cd $dir
echo "==== done ===="
}
