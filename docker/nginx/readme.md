# nginx with njs
https://github.com/nginxinc/docker-nginx/blob/master/stable/alpine/Dockerfile

## build
```bash
. init.sh
build_nginx registry.domain.com nginx latest
```
## test
```bash
docker run --name nginx -p 80:80 --rm -d registry.domain.com/nginx:latest
# note curl where your docker daemon is running not the devcontainer
curl localhost
docker exec -it nginx nginx -T
docker stop nginx
```
