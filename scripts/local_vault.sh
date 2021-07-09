function local_vault {
#local_vault [action]
#local_vault create|destroy|test
action=${1:-"create"}
dir=${PWD}
cd vault-dev
actions="create destroy test"
if [[ ! " ${actions[@]} " =~ " ${action} " ]]; then
  echo "invalid action"
fi
if [[ "${action}" == "create" ]]; then
  echo "creating"
  make vault
  echo "http://localhost:8200"
fi
if [[ "${action}" == "destroy" ]]; then
  echo "destroying"
  make destroy
fi
if [[ "${action}" == "test" ]]; then
  make test
fi
cd $dir
echo "==== done ===="
}
