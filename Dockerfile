FROM php:7.1-fpm

ARG ZPUSH_URL=http://download.z-push.org/final/2.3/z-push-2.3.9.tar.gz
ARG ZPUSH_CSUM=2c761f89f2922935d9e9ed29d5daf161
ARG USERID=1513
ARG GROUPID=1513

ENV TIMEZONE=Europe/Zurich \
  IMAP_SERVER=localhost \
  IMAP_PORT=143 \
  SMTP_SERVER=tls://localhost \
  SMTP_PORT=465

RUN set -ex \
  # Install important stuff
  && apt-get update && apt-get install -yq \
  autoconf \
  nginx \
  libssl-dev \
  libpcre3 \
  libpcre3-dev \
  supervisor \
  tar \
  wget \
  libc-client-dev \
  libkrb5-dev

ADD root /

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
  && docker-php-ext-install imap pcntl sysvmsg sysvsem sysvshm \
  && pecl install APCu-5.1.8 \
  && docker-php-ext-enable apcu \
  && apt remove -yq \
  autoconf

  # Add user for z-push
RUN groupadd --gid ${GROUPID} zpush \
  && useradd --uid ${USERID} --home-dir /opt/zpush --gid zpush --shell /sbin/nologin zpush \
  && mkdir -p /opt/zpush
  # Install z-push
RUN wget -q -O /tmp/zpush.tgz "$ZPUSH_URL" \
  && if [ "$ZPUSH_CSUM" != "$(md5sum /tmp/zpush.tgz | awk '{print($1)}')" ]; then echo "Wrong md5sum of downloaded file!"; exit 1; fi \
  && tar -zxf /tmp/zpush.tgz -C /opt/zpush --strip-components=1 \
  && rm /tmp/zpush.tgz \
  && chmod +x /usr/local/bin/docker-run.sh \
  && mv /opt/zpush/config.php /opt/zpush/config.php.dist \
  && mv /opt/zpush/backend/imap/config.php /opt/zpush/backend/imap/config.php.dist

VOLUME ["/state"]
VOLUME ["/config"]

EXPOSE 80

#ENTRYPOINT ["/sbin/tini", "--"]
CMD /usr/local/bin/docker-run.sh
