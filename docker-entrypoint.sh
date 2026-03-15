#!/bin/bash
set -e

chown -R www-data:www-data /var/www/app
setfacl -R -d -m u:www-data:rwX /var/www/app 2>/dev/null || true
setfacl -R -d -m g:www-data:rwX /var/www/app 2>/dev/null || true

exec "$@"
