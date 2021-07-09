# nginx+ with njs and app protect
https://docs.nginx.com/nginx-app-protect/admin-guide/install/#docker-deployment
## requires nginx repo keys

```bash
. init.sh
build_nginx registry.domain.com nginx-plus-ap latest nginx-plus-secret
```



## signatures
default normal signature set
```bash
printf "https://app-protect-security-updates.nginx.com/alpine/v`egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release`/main\n" | sudo tee -a /etc/apk/repositories
sudo wget -O /etc/apk/keys/app-protect-security-updates.rsa.pub https://cs.nginx.com/static/keys/app-protect-security-updates.rsa.pub
sudo apk update && sudo apk add app-protect-attack-signatures
sudo apk search app-protect-attack-signatures
sudo apk add app-protect-attack-signatures=2020.12.28-r1
```
## threat campaigns
very current signatures from soc
```bash
printf "https://app-protect-security-updates.nginx.com/alpine/v`egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release`/main\n" | sudo tee -a /etc/apk/repositories
sudo wget -O /etc/apk/keys/app-protect-security-updates.rsa.pub https://cs.nginx.com/static/keys/app-protect-security-updates.rsa.pub
sudo apk update && sudo apk add app-protect-threat-campaigns
sudo apk search app-protect-threat-campaigns
sudo apk add app-protect-threat-campaigns=2020.12.24-r1
```
## log rotate
ubuntu
```bash
sudo apt-get install logrotate
```
alpine
```bash
sudo apk add logrotate
```
```conf
/var/log/app_protect/*.log {
        size 1M
        copytruncate
        notifempty
        create 644 nginx nginx
        rotate 20
}
```
---
```nginx.conf
app_protect_security_log_enable on;
app_protect_security_log "/opt/app_protect/share/defaults/log_illegal.json" /var/log/app_protect/security.log;
```
