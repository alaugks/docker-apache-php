ARG VERSION=8.2.14
ARG ENABLE_XDEBUG="off"

FROM php:${VERSION}-apache

ARG ENABLE_XDEBUG

# > Only for debugging
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
# < Only for debugging

########################################################################################################################
# > Global
########################################################################################################################

RUN apt-get --allow-releaseinfo-change update

RUN apt-get install -y --no-install-recommends \
    git

########################################################################################################################
# > Global
########################################################################################################################

########################################################################################################################
# > PHP
########################################################################################################################

### COMPOSER
RUN curl -sSk https://getcomposer.org/installer | php -- --disable-tls --2 \
    && mv composer.phar /usr/local/bin/composer


### ZIP
RUN apt-get install -y --no-install-recommends  \
        libzip-dev \
        zip

RUN docker-php-ext-install \
        zip


### PDO
RUN docker-php-ext-install \
        pdo\
        pdo_mysql


### IMAGEMAGIK
RUN apt-get install -y --no-install-recommends \
        imagemagick \
        libmagickwand-dev \
        libwebp-dev \
        webp

RUN pecl install \
        imagick

RUN docker-php-ext-enable \
        imagick


### GD
RUN apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        zlib1g-dev \
        libicu-dev


RUN docker-php-ext-configure \
    gd \
#         --with-freetype \
          --with-jpeg \
          --with-webp \
    && docker-php-ext-install \
          gd


### INTL
RUN docker-php-ext-install \
      intl

### EXIF
RUN docker-php-ext-install \
      exif

#### XDEBUG 3
RUN touch /tmp/xdebug.log
RUN chown -Rf www-data:www-data /tmp/xdebug.log
RUN chmod 755 -Rf /tmp/xdebug.log

RUN if [ "${ENABLE_XDEBUG}" = "on" ]; then \
    pecl install xdebug-3.3.2 \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.mode=debug,develop,coverage" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.log=/tmp/xdebug.log" >> /usr/local/etc/php/conf.d/xdebug.ini \
    ; \
fi
########################################################################################################################
# < PHP
########################################################################################################################


########################################################################################################################
# > Apache
########################################################################################################################

COPY 000-default.conf /etc/apache2/sites-available

### MODULES
RUN a2enmod \
      rewrite

########################################################################################################################
# < Apache
########################################################################################################################

RUN apt-get clean

EXPOSE 80

CMD apache2-foreground
