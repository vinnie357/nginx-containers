# nginx-plus-ap-converter
tool for converting xml policies for app protect

```bash
. init.sh
build_nginx registry.domain.com nginx-plus-ap-converter latest nginx-plus-secret
```


## running
```bash
mkdir /tmp/converter
cp policy.xml /tmp/converter/
docker run -v /tmp/convert:/tmp/convert nginx-plus-ap-converter:latest /opt/app_protect/bin/convert-policy -i /tmp/convert/policy.xml -o /tmp/convert/policy.json | jq
```
