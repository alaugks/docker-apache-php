# Apache PHP (with XDebug) Docker Image

https://hub.docker.com/r/alaugks/apache-php/tags

Based on `php:8.4.26-apache`.

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
./build-local.sh --tag 8.4.26
./build-local.sh --tag 8.4.26 --with-xdebug
```

Run `./build-local.sh --help` for all options.

## Docker Compose Example

```yaml
services:
  php:
    container_name: your_projekt_local
    image: alaugks/apache-php:8.4.26-rc1-xdebug
    volumes:
      - ./app:/var/www/app
    ports:
      - "8003:80"
    environment:
      APPLICATION_ENV: "docker"
      PHP_IDE_CONFIG: "serverName=your_projekt_local"
      XDEBUG_CONFIG: "idekey=your_projekt"
```

## Frontend

Open phpinfo() with http://localhost:8080

## Docker Entrypoint

The entrypoint script sets ownership and default ACLs for `/var/www/app` to `www-data`.

## PHPUnit

```bash
vendor/bin/phpunit
```
