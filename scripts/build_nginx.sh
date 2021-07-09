function build_nginx {
# build_nginx [registry] [type] [tag] [secret]
# default tag is latest
registry=${1:-"registry.vin-lab.com"}
type=${2:-"nginx-plus"}
tag=${3:-"latest"}
secretName=${4:-"none"}
dir=${PWD}
function docker_build {
  #docker_build ${registry}/${type}:${tag}
  IMAGE=$1
  docker build -t $IMAGE .
  docker push $IMAGE
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
  # store screts
  vault_secrets $vaultHost $vaultToken $secret
  VAULT_ADDR=${vaultHost:-"http://localhost:8200"}
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
    VAULT_ADDR=${vaultHost:-"http://localhost:8200"}
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
if [[ "${type}" == "nginx" ]]; then
  echo "==== building $type:$tag ===="
  ## make nginx-oss
  cd docker/$type
  docker_build ${registry}/${type}:${tag}
fi

if [[ "${type}" == "nginx-plus" ]]; then
  echo "==== building $type:$tag ===="
  ## make nginx-plus
  cd docker/$type
  docker_build ${registry}/${type}:${tag}
  rm nginx-repo.crt nginx-repo.key
fi

if [[ "${type}" == "nginx-plus-ap" ]]; then
  echo "==== building $type:$tag ===="
  ## make nginx-plus-ap
  cd docker/$type
  docker_build ${registry}/${type}:${tag}
  rm nginx-repo.crt nginx-repo.key
fi
if [[ "${type}" == "nginx-plus-ap-converter" ]]; then
  echo "==== building $type:$tag ===="
  ## make nginx-plus-ap-converter
  cd docker/$type
  docker_build ${registry}/${type}:${tag}
  rm nginx-repo.crt nginx-repo.key
fi
if [[ "${type}" == "nginx-plus-ap-dos" ]]; then
  echo "==== building $type:$tag ===="
  ## make nginx-plus-ap-dos
  cd docker/$type
  docker_build ${registry}/${type}:${tag}
  rm nginx-repo.crt nginx-repo.key
fi
cd $dir
echo "==== done ===="
}
