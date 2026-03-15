# Apache PHP (with XDebug) Docker Image

https://hub.docker.com/r/alaugks/apache-php/tags

Based on `php:8.4.18-apache`.

## PHP Modules

Core, ctype, curl, date, dom, exif, fileinfo, filter, gd, hash, iconv, imagick, intl, json, libxml, mbstring, mysqli, mysqlnd, openssl, pcre, PDO, pdo_mysql, pdo_sqlite, Phar, posix, random, readline, redis, Reflection, session, SimpleXML, sodium, SPL, sqlite3, standard, tokenizer, xml, xmlreader, xmlwriter, zip, zlib

## Build

### Build without XDebug

```bash
docker compose -f docker-compose.yml up -d --build
```

### Build with XDebug

```bash
docker compose -f docker-compose-xdebug.yml up -d --build
```

### Local Build Script

```bash
./build-local.sh
./build-local.sh --tag 8.4.18
./build-local.sh --tag 8.4.18 --with-xdebug
```

Run `./build-local.sh --help` for all options.

## Frontend

Open phpinfo() with http://localhost:8080

## Docker Entrypoint

The entrypoint script sets ownership and default ACLs for `/var/www/app` to `www-data`.

## PHPUnit

```bash
vendor/bin/phpunit
```
