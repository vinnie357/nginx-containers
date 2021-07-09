# nginx+ with njs and app protect dos
https://docs.nginx.com/nginx-app-protect-dos/deployment-guide/learn-about-deployment/#docker-deployment-instructions

## requires nginx repo keys

## build

```bash
. init.sh
build_nginx registry.domain.com nginx-plus-ap-dos latest nginx-plus-secret
```
## test
```bash
docker run --name nginx-plus-ap-dos -p 80:80 --rm -d registry.domain.com/nginx-plus-ap-dos:latest
# note curl where your docker daemon is running not the devcontainer
curl localhost
docker exec -it nginx-plus-ap-dos nginx -T
docker stop nginx-plus-ap-dos
```
