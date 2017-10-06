#!/bin/sh

if [ -z "$(ls -A "/etc/nginx/ssl")" ]; then
  # nginx setup
  mkdir -p /etc/nginx/ssl
  chmod 600 -R /etc/nginx/ssl
  openssl req  -nodes -new -x509  -keyout /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.crt -subj "/C=$COUNTRY/ST=/L=/O=$COMPANY/OU=DevOps/CN=$APP_DOMAIN/emailAddress=$SUPPORT_EMAIL"
fi

echo "=======nginx======="
exec nginx &

chown -R postgres "$PGDATA"

if [ -z "$(ls -A "$PGDATA")" ]; then
    gosu postgres initdb
    sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf

    : ${POSTGRES_USER:="postgres"}
    : ${POSTGRES_DB:=$POSTGRES_USER}

    if [ "$POSTGRES_PASSWORD" ]; then
      pass="PASSWORD '$POSTGRES_PASSWORD'"
      authMethod=md5
    else
      echo "==============================="
      echo "!!! Use \$POSTGRES_PASSWORD env var to secure your database !!!"
      echo "==============================="
      pass=
      authMethod=trust
    fi
    echo


    if [ "$POSTGRES_DB" != 'postgres' ]; then
      createSql="CREATE DATABASE $POSTGRES_DB;"
      echo $createSql | gosu postgres postgres --single -jE
      echo
    fi

    if [ "$POSTGRES_USER" != 'postgres' ]; then
      op=CREATE
    else
      op=ALTER
    fi

    userSql="$op USER $POSTGRES_USER WITH SUPERUSER $pass;"
    echo $userSql | gosu postgres postgres --single -jE
    echo

    # internal start of server in order to allow set-up using psql-client
    # does not listen on TCP/IP and waits until start finishes
    gosu postgres pg_ctl -D "$PGDATA" \
        -o "-c listen_addresses=''" \
        -w start

    echo
    for f in /docker-entrypoint-initdb.d/*; do
        case "$f" in
            *.sh)  echo "$0: running $f"; . "$f" ;;
            *.sql) echo "$0: running $f"; psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" < "$f" && echo ;;
            *)     echo "$0: ignoring $f" ;;
        esac
        echo
    done

    gosu postgres pg_ctl -D "$PGDATA" -m fast -w stop

    { echo; echo "host all all 0.0.0.0/0 $authMethod"; } >> "$PGDATA"/pg_hba.conf

    # pg ssl setup
    openssl req  -nodes -new -x509  -keyout $PGDATA/server.key -out $PGDATA/server.crt -subj "/C=$COUNTRY/ST=/L=/O=$COMPANY/OU=DevOps/CN=$APP_DOMAIN/emailAddress=$SUPPORT_EMAIL"
    chown postgres:postgres $PGDATA/server.key $PGDATA/server.crt
    chmod 0600 $PGDATA/server.key $PGDATA/server.crt
    sed -i "s|#\?ssl \?=.*|ssl = on|g" $PGDATA/postgresql.conf
fi

echo "=======starting postgres======="

exec gosu postgres postgres &
#exec gosu postgres "$@"
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

exec gosu /usr/sbin/sshd -D &

mkdir -p /home/app/web/log

cd /home/app/web && exec gosu app bin/heroku > /home/app/web/log/out.log

# while true; do sleep 1000; done
