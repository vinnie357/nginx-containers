# For Ubuntu 20.04:
FROM ubuntu:focal

# Download certificate and key from the customer portal (https://my.f5.com)
# and copy to the build context:
COPY nginx-repo.crt nginx-repo.key /etc/ssl/nginx/

# Install prerequisite packages:
RUN apt-get update && apt-get install -y apt-transport-https lsb-release ca-certificates wget gnupg2

# Download and add the NGINX signing key:
RUN wget https://cs.nginx.com/static/keys/nginx_signing.key && apt-key add nginx_signing.key

# Add NGINX Plus and NGINX App Protect DoS repository:
RUN printf "deb https://pkgs.nginx.com/plus/ubuntu `lsb_release -cs` nginx-plus\n" | tee /etc/apt/sources.list.d/nginx-plus.list
RUN printf "deb https://pkgs.nginx.com/app-protect-dos/ubuntu `lsb_release -cs` nginx-plus\n" | tee /etc/apt/sources.list.d/nginx-app-protect-dos.list

# Download the apt configuration to `/etc/apt/apt.conf.d`:
RUN wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx

# Update the repository and install the most recent version of the NGINX App Protect DoS package (which includes NGINX Plus):
RUN apt-get update && apt-get install -y app-protect-dos

# Remove nginx repository key/cert from docker
RUN rm -rf /etc/ssl/nginx

# Copy configuration files:
COPY nginx.conf /etc/nginx/
COPY entrypoint.sh /root/

CMD /root/entrypoint.sh && tail -f /dev/null
