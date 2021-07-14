# nginx+ with njs
https://gist.github.com/nginx-gists/36e97fc87efb5cf0039978c8e41a34b5#file-dockerfile

 - nginx+
 - njs
 - nginx-agent

## requires nginx repo keys

## build
```bash
. init.sh
build_nginx registry.domain.com nginx-plus latest nginx-plus-secret
```

## test
```bash
docker run --hostname nginx-plus-docker --name nginx-plus -p 80:80 --rm -d registry.domain.com/nginx-plus:latest
# note curl where your docker daemon is running not the devcontainer
curl localhost
docker exec -it nginx-plus nginx -T
docker stop nginx-plus
```
