# For Alpine 3.10:
FROM alpine:3.10

# Download certificate and key from the customer portal (https://my.f5.com)
# and copy to the build context:
COPY nginx-repo.key /etc/apk/cert.key
COPY nginx-repo.crt /etc/apk/cert.pem

# Download and add the NGINX signing key:
RUN wget -O /etc/apk/keys/nginx_signing.rsa.pub https://cs.nginx.com/static/keys/nginx_signing.rsa.pub

# Add NGINX Plus repository:
RUN printf "https://plus-pkgs.nginx.com/alpine/v`egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release`/main\n" | tee -a /etc/apk/repositories

# Update the repository and install the most recent version of the NGINX App Protect package (which includes NGINX Plus):
RUN apk update && apk add app-protect

# Remove nginx repository key/cert from docker
RUN rm -rf /etc/apk/cert.*

# Forward request logs to Docker log collector:
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Copy configuration files:
COPY nginx.conf custom_log_format.json /etc/nginx/
COPY entrypoint.sh  /root/

CMD ["sh", "/root/entrypoint.sh"]
