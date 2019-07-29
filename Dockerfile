FROM alpine:3.10.0

RUN \

# Install dependencies
    apk add --update --upgrade --no-cache supervisor nginx php7-fpm php7-json php7-gd php7-opcache \
        php7-pdo_mysql php-pear php7-dev \
        autoconf g++ imagemagick imagemagick-dev libtool make pcre-dev musl-dev \
#        $PHPIZE_DEPS openssl-dev \
        && pecl config-set php_ini  /usr/local/etc/php/php.ini \
        && pecl channel-update pecl.php.net \
        && pecl install imagick \
#        && docker-php-ext-enable imagick \
        && apk del autoconf g++ libtool make pcre-dev \

# Remove (some of the) default nginx config
    && rm -f /etc/nginx.conf \
    && rm -f /etc/nginx/conf.d/default.conf \
    && rm -rf /etc/nginx/sites-* \
    && rm -rf /var/log/nginx \

# Ensure nginx logs, even if the config has errors, are written to stderr
    && rm /var/lib/nginx/logs \
    && mkdir -p /var/lib/nginx/logs \
    && ln -s /dev/stderr /var/lib/nginx/logs/error.log \

# Create folder where the user hook into our default configs
    && mkdir -p /etc/nginx/server.d/ \
    && mkdir -p /etc/nginx/location.d/ \

WORKDIR /var/www

ADD etc/ /etc/

# mark dirs as volumes that need to be writable, allows running the container --read-only
VOLUME /srv/data /tmp /var/tmp /run /var/log

EXPOSE 80

ENTRYPOINT ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
