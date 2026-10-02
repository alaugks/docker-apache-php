FROM php:8.2.34-apache@sha256:a5ca3797b19e8ba69905233f79fae6db191d2477f8e6d5194f2c05f01e22e104 AS base

SHELL ["/bin/bash", "-c"]

########################################################################################################################
# > Global + PHP
########################################################################################################################

### System packages (git, acl, composer, zip, imagick, gd, intl)
RUN apt-get --allow-releaseinfo-change update --fix-missing \
    && apt-get install -y --no-install-recommends \
        git \
        acl \
        libzip-dev \
        zip \
        unzip \
        imagemagick \
        libmagickwand-dev \
        libwebp-dev \
        webp \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        zlib1g-dev \
        libicu-dev \
    && rm -rf /var/lib/apt/lists/*

### COMPOSER
RUN curl -fsSL -o /usr/local/bin/composer https://raw.githubusercontent.com/composer/getcomposer.org/ef2ebcfdd80b3ca949aafa5c0e8d281755ab2442/web/download/2.10.3/composer.phar \
    && chmod +x /usr/local/bin/composer

### PHP extensions (zip, pdo, pdo_mysql, mysqli, gd, intl, exif, imagick, redis)
RUN docker-php-ext-configure gd --with-jpeg --with-webp \
    && docker-php-ext-install -j"$(nproc)" \
        zip \
        pdo \
        pdo_mysql \
        mysqli \
        gd \
        intl \
        exif \
    && pecl install imagick redis \
    && docker-php-ext-enable imagick redis \
    && rm -rf /tmp/pear

########################################################################################################################
# < Global + PHP
########################################################################################################################


########################################################################################################################
# > Apache
########################################################################################################################

COPY 000-default.conf /etc/apache2/sites-available

### MODULES
RUN a2enmod rewrite

########################################################################################################################
# < Apache
########################################################################################################################

EXPOSE 80

WORKDIR /var/www/app

# Ensure Apache runs as www-data (already default in base image, but explicit here)
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data

COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]

########################################################################################################################
# > Target: xdebug (development)
########################################################################################################################

FROM base AS xdebug

RUN touch /tmp/xdebug.log \
    && chown www-data:www-data /tmp/xdebug.log \
    && chmod 755 /tmp/xdebug.log \
    && pecl install xdebug-3.5.3 \
    && { \
        echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)"; \
        echo "xdebug.mode=debug,develop,coverage"; \
        echo "xdebug.client_host=host.docker.internal"; \
        echo "xdebug.start_with_request=yes"; \
        echo "xdebug.log=/tmp/xdebug.log"; \
    } > /usr/local/etc/php/conf.d/xdebug.ini \
    && rm -rf /tmp/pear

########################################################################################################################
# < Target: xdebug
########################################################################################################################


########################################################################################################################
# > Target: production (default, last stage)
########################################################################################################################

FROM base AS production

########################################################################################################################
# < Target: production
########################################################################################################################
