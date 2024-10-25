# Apache PHP (with XDebug) Docker Image

https://hub.docker.com/r/alaugks/apache-php/tags

## PHP Modules

Core, ctype, curl, date, dom, exif, fileinfo, filter, gd, hash, iconv, imagick, intl, json, libxml, mbstring, mysqlnd, openssl, pcre, PDO, pdo_mysql, pdo_sqlite, Phar, posix, random, readline, Reflection, session, SimpleXML, sodium, SPL, sqlite3, standard, tokenizer, xml, xmlreader, xmlwriter, zip, zlib

##  Build

### Build without XDebug

```bash
docker compose -f docker-compose.yml up -d --build
```

### Build witt XDebug

```bash
docker compose -f docker-compose-xdebug.yml up -d --build
```

##  Frontend

Open phpinfo() with http://localhost:8080

##  PHPUnit

```bash
vendor/bin/phpunit
```
