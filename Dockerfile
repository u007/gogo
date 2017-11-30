FROM nginx:1-alpine
MAINTAINER James <c00lways@gmail.com>

ENV ACMETOOL_VERSION=0.0.61

RUN apk update \
  &&  apk add ca-certificates openssl curl tar gzip

RUN cd /usr/local/bin && \
  curl -L https://github.com/hlandau/acme/releases/download/v$ACMETOOL_VERSION/acmetool-v$ACMETOOL_VERSION-linux_amd64.tar.gz | tar xz --strip-components=2

RUN update-ca-certificates

# ==========================================
# wkhtmltopdf

# thanks to: https://github.com/madnight/docker-alpine-wkhtmltopdf
#RUN apk add --update --no-cache \
#    libgcc libstdc++ libx11 glib libxrender libxext libintl \
#    libcrypto1.0 libssl1.0 \
#    ttf-dejavu ttf-droid ttf-freefont ttf-liberation ttf-ubuntu-font-family

# on alpine static compiled patched qt headless wkhtmltopdf (47.2 MB)
# compilation takes 4 hours on EC2 m1.large in 2016 thats why binary
# COPY wkhtmltopdf /bin
# RUN chmod a+x /bin/wkhtmltopdf


# thanks to: https://github.com/nginxinc/docker-nginx/blob/master/stable/alpine/Dockerfile

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/nginx.vh.default-pre.conf /etc/nginx/default.conf-pre.template
COPY nginx/nginx.vh.default.conf /etc/nginx/default.conf.template
COPY nginx/nginx.vh.control-default.conf /etc/nginx/control-default.conf.template
COPY nginx/acme-client.sh /etc/periodic/weekly/acme-client.sh
COPY nginx/acme-config.yml /etc/nginx/acme-config.template
COPY docker-entrypoint.sh /
# thanks to https://github.com/jwilder/nginx-proxy/blob/master/Dockerfile.alpine


# ==========================================
# ssh
# thanks to https://hub.docker.com/r/gotechnies/alpine-ssh
#RUN apk --update add --no-cache openssh bash curl \
#  && sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
#  && rm -rf /var/cache/apk/*
#RUN sed -ie 's/#Port 22/Port 2022/g' /etc/ssh/sshd_config
#RUN sed -ri 's/#HostKey \/etc\/ssh\/ssh_host_key/HostKey \/etc\/ssh\/ssh_host_key/g' /etc/ssh/sshd_config
#RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_rsa_key/HostKey \/etc\/ssh\/ssh_host_rsa_key/g' /etc/ssh/sshd_config
#RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_dsa_key/HostKey \/etc\/ssh\/ssh_host_dsa_key/g' /etc/ssh/sshd_config
#RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/g' /etc/ssh/sshd_config
#RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/HostKey \/etc\/ssh\/ssh_host_ed25519_key/g' /etc/ssh/sshd_config
#RUN /usr/bin/ssh-keygen -A
#RUN ssh-keygen -t rsa -b 4096 -f  /etc/ssh/ssh_host_key

#RUN echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
#    apk update && \
#    curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64" && \
#    chmod +x /usr/local/bin/gosu && \
#    rm -rf /var/cache/apk/*

# ==========================================
# custom config

RUN mkdir -p /var/log/nginx && chmod a+rwx -R /var/log/nginx && \
	mkdir -p /var/cache/nginx && chmod 777 -R /var/cache/nginx && \
	mkdir -p /var/log/nginx && chmod a+rwx -R /var/log && \
	chmod a+x /etc/periodic/weekly/acme-client.sh && \
	chmod a+x /docker-entrypoint.sh

ENV APP_ENDPOINT "http://127.0.0.1:3000"
ENV PORT "3000"
ENV APP_DOMAIN "example.com"
ENV DOCKER_CONTROL_HOST ""
ENV SUPPORT_EMAIL "info@example.com"
ENV COMPANY "Example Inc."
ENV COUNTRY "MY"
ENV GENERATE_SSL "0"
ENV DOCKER_HOST unix:///tmp/docker.sock
ENV LANG en_US.utf8

# ==========================================
# finalize

RUN adduser -h /home/app -D -s /bin/bash -g app,sudo app && \
	mkdir -p /home/app/web && \
	mkdir -p /home/app/.ssh && \
	touch /home/app/.ssh/authorized_keys && \
	chmod 600 /home/app/.ssh/authorized_keys && \
	chmod 700 /home/app/.ssh && \
	chown -R app:app /home/app

#nginx, ssl
EXPOSE 80 443 3000 2022
WORKDIR /home/app/web

#STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME ["/etc/nginx/conf.d", "/etc/ssl", "/home/app"]


