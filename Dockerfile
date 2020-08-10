FROM php:7.2-fpm-alpine

LABEL maintainer Lerry1

RUN apk add --no-cache --virtual .build-deps \
      $PHPIZE_DEPS \
      libtool \
      icu-dev \
      curl-dev \
      freetype-dev \
      git\
      imagemagick-dev \
      pcre-dev \
      postgresql-dev \
      libjpeg-turbo-dev \
      libpng-dev \
      libzip-dev \
      libxml2-dev; \
    docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/; \
    docker-php-ext-configure bcmath; \
    docker-php-ext-install \
        soap \
        bcmath \
        exif \
        gd \
        zip \
        intl \
        pdo_mysql \
        tokenizer \
        xml \
        pcntl \
        pgsql \
        pdo_pgsql \
        opcache && \
        pecl channel-update pecl.php.net; \
    printf "\n" | pecl install -o -f \
        redis \
        xhprof \
        swoole;\
    docker-php-ext-enable \
        redis\
        xhprof \
        swoole; \
    docker-php-source delete; \
    runDeps="$( \
      scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
        | tr ',' '\n' \
        | sort -u \
        | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
	  apk add --no-cache $runDeps; \
	  apk del --no-network .build-deps; \
    rm -rf /tmp/pear /var/cache/apk/* ~/.pearrc

WORKDIR /var/www

CMD ["php-fpm"]

EXPOSE 9000


