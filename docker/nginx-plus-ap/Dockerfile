FROM ubuntu:focal as agent

# packages
RUN set -x \
&& apt update \
&& apt install -y \
 jq \
 apt-transport-https \
 lsb-release \
 ca-certificates \
 wget \
 gnupg \
# folders
&& mkdir /etc/ssl/nginx/

COPY nginx-repo.crt /etc/ssl/nginx/nginx-repo.crt
COPY nginx-repo.key /etc/ssl/nginx/nginx-repo.key

RUN set -x \
  && wget https://nginx.org/keys/nginx_signing.key \
  && apt-key add nginx_signing.key \
  && printf "deb https://pkgs.nginx.com/instance-manager/debian stable nginx-plus\n" | tee /etc/apt/sources.list.d/instance-manager.list \
  && wget -q -O /etc/apt/apt.conf.d/90pkgs-nginx https://cs.nginx.com/static/files/90pkgs-nginx \
  && apt update \
  && apt install -y nginx-agent \
  && rm -f /etc/ssl/nginx/nginx-repo.crt /etc/ssl/nginx/nginx-repo.key

# For Alpine 3.10:
FROM alpine:3.10 as final

# Download certificate and key from the customer portal (https://my.f5.com)
# and copy to the build context:
COPY nginx-repo.key /etc/apk/cert.key
COPY nginx-repo.crt /etc/apk/cert.pem
# copy agent binary from previous layer
COPY --from=agent /usr/sbin/nginx-agent /usr/sbin/nginx-agent

# Download and add the NGINX signing key:
RUN wget -O /etc/apk/keys/nginx_signing.rsa.pub https://cs.nginx.com/static/keys/nginx_signing.rsa.pub

# Add NGINX Plus repository:
RUN printf "https://plus-pkgs.nginx.com/alpine/v`egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release`/main\n" | tee -a /etc/apk/repositories

# # Update the repository and install the most recent version of the NGINX App Protect package (which includes NGINX Plus):
# RUN apk update && apk add app-protect
# apparently not... thanks for the catch @gallarda
RUN apk update && apk add nginx-plus app-protect

# Remove nginx repository key/cert from docker
RUN rm -rf /etc/apk/cert.*

# Forward request logs to Docker log collector:
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
#We will need to add dbus for the machine-id generation.
#https://docs.nginx.com/nginx-instance-manager/tutorials/containers/#single
    && apk add dbus \
    && dbus-uuidgen > /var/lib/dbus/machine-id \
    && ln -sf /etc/machine-id /var/lib/dbus/machine-id \
# agent folders
    && mkdir /var/log/nginx-agent/ /etc/nginx-agent/
# agent config
COPY nginx-agent.conf /etc/nginx-agent/nginx-agent.conf
COPY stub-status.conf /etc/nginx/conf.d/

# Copy configuration files:
COPY nginx.conf custom_log_format.json /etc/nginx/
COPY entrypoint.sh .

RUN chmod +x ./entrypoint.sh

CMD ["/bin/sh","./entrypoint.sh"]

# vim:syntax=Dockerfile
