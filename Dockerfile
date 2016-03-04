FROM ubuntu:14.04.3
MAINTAINER Krishna Pennacchioni <krishna@agentelinux.com.br>

# Surpress Upstart errors/warning
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Update base image
# Add sources for latest nginx
# Install software requirements
RUN apt-get update && \
apt-get install -y software-properties-common && \
nginx=stable && \
add-apt-repository ppa:nginx/$nginx && \
apt-get update && \
apt-get upgrade -y && \
BUILD_PACKAGES="supervisor nginx vsftpd git pwgen" && \
apt-get -y install $BUILD_PACKAGES && \
apt-get remove --purge -y software-properties-common && \
apt-get autoremove -y && \
apt-get clean && \
apt-get autoclean && \
echo -n > /var/lib/apt/extended_states && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /usr/share/man/?? && \
rm -rf /usr/share/man/??_*

# tweak nginx config
RUN sed -i -e"s/worker_processes  1/worker_processes 5/" /etc/nginx/nginx.conf && \
sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf && \
sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf && \
echo "daemon off;" >> /etc/nginx/nginx.conf


# nginx site conf
RUN rm -Rf /etc/nginx/conf.d/* && \
rm -Rf /etc/nginx/sites-available/default && \
mkdir -p /etc/nginx/ssl/
ADD ./nginx-site.conf /etc/nginx/sites-available/default.conf
RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

# vsftp conf
ADD vsftpd.conf /etc/vsftpd.conf
RUN chown root:root /etc/vsftpd.conf
ADD users.sh /usr/local/
ADD add_users_in_container.sh /usr/local/
RUN echo "/usr/sbin/nologin" >> /etc/shells


# Add git commands to allow container updating
ADD ./pull /usr/bin/pull
ADD ./push /usr/bin/push
RUN chmod 755 /usr/bin/pull && chmod 755 /usr/bin/push

# Supervisor Config
ADD ./supervisord.conf /etc/supervisord.conf

# Start Supervisord
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

# Setup Volume
VOLUME ["/usr/share/nginx/html"]

# add test PHP file
RUN chown -Rf www-data.www-data /usr/share/nginx/html/

# Expose Ports
EXPOSE 443
EXPOSE 80
EXPOSE 21 
EXPOSE 22 

CMD ["/bin/bash", "/start.sh"]
