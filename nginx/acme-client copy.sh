#!/bin/sh
set -e
echo "acme-client: setup $APP_DOMAIN"

ls -lath /var/www/acme

# -s = staging
if [ "$TEST" -eq "1" ]; then
	echo "Generating test $APP_DOMAIN"
	acme-client -s -a https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf -Nnmv $APP_DOMAIN && renew=1
else
	echo "Generating $APP_DOMAIN"
	acme-client -a https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf -Nnmv $APP_DOMAIN && renew=1
fi

echo "Reloading nginx..."
[ "$renew" = 1 ] && nginx -s reload

ls -lath /var/www/acme

set +e
