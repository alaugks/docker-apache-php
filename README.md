# Apache PHP (with XDebug) Docker Image

https://hub.docker.com/r/alaugks/apache-php/tags

### PHP Modules
Core, ctype, curl, date, dom, exif, fileinfo, filter, gd, hash, iconv, imagick, intl, json, libxml, mbstring, mysqlnd, openssl, pcre, PDO, pdo_mysql, pdo_sqlite, Phar, posix, random, readline, Reflection, session, SimpleXML, sodium, SPL, sqlite3, standard, tokenizer, xml, xmlreader, xmlwriter, zip, zlib

##  Installation

Pull the latest version of the image.

```bash
docker pull alaugks/apache-php:8.2.21-v1.0-xdebug
```
Alternately you can build the image yourself.

```bash
git clone https://github.com/romeoz/docker-apache-php.git
```


### Quick Start

Use Docker Image wothout 

```bash
docker pull alaugks/apache-php:8.2.21-v1.0-xdebug

docker run --name app -d \
  -p 8080:80 \
  -v /host/to/path:/var/www/app \
  -e  "PHP_IDE_CONFIG=serverName=localhost"
  -e  "XDEBUG_CONFIG=idekey=xdebug_test"
  alaugks/apache-php:8.2.21-v1.0-xdebug
```
