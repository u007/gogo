#!/bin/sh

echo "acme-client: setup $APP_DOMAIN"

ls -lath /var/www/acme

# -s = staging
acme-client -a https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf -Nnmv $APP_DOMAIN && renew=1

[ "$renew" = 1 ] && nginx -s reload

ls -lath /var/www/acme
