#!/bin/sh

if [ -z "$(ls -A "/etc/nginx/ssl")" ]; then
  # nginx setup
  mkdir -p /etc/nginx/ssl
  chmod 600 -R /etc/nginx/ssl
  openssl req  -nodes -new -x509  -keyout /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.crt -subj "/C=$COUNTRY/ST=/L=/O=$COMPANY/OU=DevOps/CN=$APP_DOMAIN/emailAddress=$SUPPORT_EMAIL"
fi

echo "=======nginx======="

#fix $uri used in template
export DOLLAR='$'
export uri="\$uri"

envsubst < /etc/nginx/default.conf.template > /etc/nginx/conf.d/default.conf

exec nginx &
#exec $@

if [ "$SSH_KEY" ]; then
  echo "$SSH_KEY
      " > /home/app/.ssh/authorized_keys
  if [ "$SSH_KEY2" ]; then
      echo "$SSH_KEY2
      " >> /home/app/.ssh/authorized_keys
  fi
  if [ "$SSH_KEY3" ]; then
      echo "$SSH_KEY3
      " >> /home/app/.ssh/authorized_keys
  fi
  if [ "$SSH_KEY4" ]; then
      echo "$SSH_KEY4
      " >> /home/app/.ssh/authorized_keys
  fi
  if [ "$SSH_KEY5" ]; then
      echo "$SSH_KEY5
      " >> /home/app/.ssh/authorized_keys
  fi
fi

# exec gosu /usr/sbin/sshd -D &
# mkdir -p /home/app/web/log
# cd /home/app/web && exec gosu app bin/heroku > /home/app/web/log/out.log

while true; do sleep 1000; done
