# For Ubuntu 20.04:
FROM ubuntu:focal
#apt list -a nginx-manager
ENV NIM_VERSION '1.0.1-336280068'
# Download certificate and key from the customer portal (https://my.f5.com)
# and copy to the build context:
COPY nginx-repo.crt nginx-repo.key /etc/ssl/nginx/

# Install prerequisite packages:
RUN apt-get update
RUN set -x \
apt-get update && apt-get install -y \
apt-transport-https \
lsb-release \
ca-certificates \
wget \
gnupg2 \
# Download and add the NGINX signing key:
&& wget https://cs.nginx.com/static/keys/nginx_signing.key && apt-key add nginx_signing.key \
# Add NGINX Plus and NGINX App Protect DoS repository:
&& printf "deb https://pkgs.nginx.com/plus/ubuntu `lsb_release -cs` nginx-plus\n" | tee /etc/apt/sources.list.d/nginx-plus.list \
&& printf "deb https://pkgs.nginx.com/app-protect-dos/ubuntu `lsb_release -cs` nginx-plus\n" | tee /etc/apt/sources.list.d/nginx-app-protect-dos.list \
&& printf "deb https://pkgs.nginx.com/instance-manager/debian stable nginx-plus\n" | tee /etc/apt/sources.list.d/instance-manager.list \
# Download the apt configuration to `/etc/apt/apt.conf.d`:
&& wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx \
&& wget -q -O /etc/apt/apt.conf.d/90pkgs-nginx https://cs.nginx.com/static/files/90pkgs-nginx \
# Update the repository and install the most recent version of the NGINX App Protect DoS package (which includes NGINX Plus):
&& apt update && apt install -y app-protect-dos \
## install nginx-agent
&& apt clean \
&& apt install -y nginx-agent=${NIM_VERSION} \
# Remove nginx repository key/cert from docker
&& rm -rf /etc/ssl/nginx

# Copy configuration files:
COPY nginx.conf /etc/nginx/
COPY entrypoint.sh .
# Agent config
COPY nginx-agent.conf /etc/nginx-agent/nginx-agent.conf
COPY stub-status.conf /etc/nginx/conf.d/

RUN chmod +x ./entrypoint.sh

EXPOSE 80

CMD ["/bin/sh","./entrypoint.sh"]

#CMD /root/entrypoint.sh && tail -f /dev/null

# vim:syntax=Dockerfile
