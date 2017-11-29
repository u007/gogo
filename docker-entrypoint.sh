#!/bin/sh

# if [ $# -ne 0 ]; then
#   exec $@
# fi
echo "=======nginx======="
if [ -z "$(ls -A "/etc/ssl/acme/$APP_DOMAIN")" ]; then
  # nginx setup

  # generate ssl
  if [ "$GENERATE_SSL" -eq "1" ]; then
    echo "setting up /etc/ssl/acme/$APP_DOMAIN"
    sed "s/\${host}/$APPHost/" /etc/nginx/default.conf-pre.template | sed "s/\${dockerhost}/$DOCKERMAIN_HOST/" | sed "s/\${APP_DOMAIN}/$APP_DOMAIN/" > /etc/nginx/conf.d/default.conf

    export ACME_URL="https:\/\/acme-v01.api.letsencrypt.org\/directory"
    if [ "$TEST" -eq "1" ]; then
      export ACME_URL="https:\/\/acme-staging.api.letsencrypt.org\/directory"
    fi

    sed "s/\${host}/$APPHost/" /etc/nginx/acme-config.template | sed "s/\${email}/$SUPPORT_EMAIL/" | sed "s/\${APP_DOMAIN}/$APP_DOMAIN/" | sed "s/\${ACME_URL}/$ACME_URL/" > /etc/nginx/acme-config.yml

    cat /etc/nginx/acme-config.yml

    exec nginx &

    mkdir -p /etc/ssl/acme/
    chmod 600 -R /etc/ssl/acme/
    exec /etc/periodic/weekly/acme-client.sh

    echo "ssl setup done..."
    rm -f /etc/nginx/conf.d/default.conf
    exec nginx -s stop
    # openssl req  -nodes -new -x509  -keyout /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.crt -subj "/C=$COUNTRY/ST=/L=/O=$COMPANY/OU=DevOps/CN=$APP_DOMAIN/emailAddress=$SUPPORT_EMAIL"
  fi

else
  echo "exists: "/etc/ssl/acme/$APP_DOMAIN""
fi

ls -lath /etc/ssl/acme/$APP_DOMAIN

# always override
export DOCKERMAIN_HOST=$(route -n | awk '/UG[ \t]/{print $2}')
if [ "$GENERATE_SSL" -eq "1" ]; then
  sed "s/\${host}/$APPHost/" /etc/nginx/control-default.conf.template | sed "s/\${dockerhost}/$DOCKERMAIN_HOST/" | sed "s/\${APP_DOMAIN}/$APP_DOMAIN/" > /etc/nginx/conf.d/default.conf
else
  sed "s/\${host}/$APPHost/" /etc/nginx/default.conf.template | sed "s/\${dockerhost}/$DOCKERMAIN_HOST/" | sed "s/\${APP_DOMAIN}/$APP_DOMAIN/" | sed "s/\${DOCKER_CONTROL_HOST}/$DOCKER_CONTROL_HOST/" > /etc/nginx/conf.d/default.conf
fi

cat /etc/nginx/conf.d/default.conf

if [ $# -eq 0 ]; then
  echo "starting nginx"
  exec nginx -g 'daemon off;'
else
  exec $@
  # while true; do sleep 1000; done
fi
#exec $@

# if [ "$SSH_KEY" ]; then
#   echo "$SSH_KEY
#       " > /home/app/.ssh/authorized_keys
#   if [ "$SSH_KEY2" ]; then
#       echo "$SSH_KEY2
#       " >> /home/app/.ssh/authorized_keys
#   fi
#   if [ "$SSH_KEY3" ]; then
#       echo "$SSH_KEY3
#       " >> /home/app/.ssh/authorized_keys
#   fi
#   if [ "$SSH_KEY4" ]; then
#       echo "$SSH_KEY4
#       " >> /home/app/.ssh/authorized_keys
#   fi
#   if [ "$SSH_KEY5" ]; then
#       echo "$SSH_KEY5
#       " >> /home/app/.ssh/authorized_keys
#   fi
# fi

# exec gosu /usr/sbin/sshd -D &
# mkdir -p /home/app/web/log
# cd /home/app/web && exec gosu app bin/heroku > /home/app/web/log/out.log


