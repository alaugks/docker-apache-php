ARG ENABLE_XDEBUG="0"

FROM php:8.4.18-apache@sha256:f136434142729ffb11936a2dadd898812bbbc94eae23e9e1b2476b81e313eea0

ARG ENABLE_XDEBUG

# > Only for debugging
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
# < Only for debugging

########################################################################################################################
# > Global
########################################################################################################################

RUN apt-get --allow-releaseinfo-change update --fix-missing

RUN apt-get install -y --no-install-recommends \
    git \
    acl

########################################################################################################################
# > Global
########################################################################################################################

########################################################################################################################
# > PHP
########################################################################################################################

### COMPOSER
RUN curl -o composer.phar https://raw.githubusercontent.com/composer/getcomposer.org/09a1f131c28d6c496f6bddcbf6cebf34502ad9bc/web/download/2.9.5/composer.phar \
    && mv composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer


### ZIP
RUN apt-get install -y --no-install-recommends  \
        libzip-dev \
        zip \
        unzip

RUN docker-php-ext-install \
        zip


### PDO
RUN docker-php-ext-install \
        pdo\
        pdo_mysql

### mysqli
RUN docker-php-ext-install mysqli

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

# Redis
RUN pecl install redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

#### XDEBUG 3
RUN touch /tmp/xdebug.log
RUN chown -Rf www-data:www-data /tmp/xdebug.log
RUN chmod 755 -Rf /tmp/xdebug.log

RUN if [ "${ENABLE_XDEBUG}" = "1" ]; then \
    pecl install xdebug-3.5.0 \
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

WORKDIR /var/www/app

# Ensure Apache runs as www-data (already default in base image, but explicit here)
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
