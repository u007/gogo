#!/bin/sh
set -e
echo "acme-client(v2.0.1):(deprecated, use docker xenolf/lego) setup $APP_DOMAIN"

export ACMEPATH=/usr/local/bin/acmetool
# ls -lath /var/www/acme
mkdir -p /root/.config/acme/
ls -lath /root/.config/acme

echo "generate user $SUPPORT_EMAIL"

# -s = staging
if [ "$TEST" -eq "1" ]; then
	echo "Generating test $APP_DOMAIN"
	$ACMEPATH --batch --response-file /etc/nginx/acme-config.yml want $APP_DOMAIN
	# acme-client -s -a https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf -Nnmv $APP_DOMAIN && renew=1
else
	echo "Generating $APP_DOMAIN"
	# acme-client -a https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf -Nnmv $APP_DOMAIN && renew=1
	$ACMEPATH --batch --response-file /etc/nginx/acme-config.yml want $APP_DOMAIN
fi

ls -lath /root/.config/acme
# cp ~/.config/acme/

echo "Reloading nginx..."
[ "$renew" = 1 ] && nginx -s reload

set +e
