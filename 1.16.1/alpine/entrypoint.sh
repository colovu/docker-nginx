#!/bin/sh
# docker entrypoint script

echo "[i] Initial Container"

if [ ! -d /var/log/nginx ]; then
  echo "[i] Create directory: /var/log/nginx"
  mkdir -p /var/log/nginx
fi

if [ ! -d /srv/www/default ]; then
  echo "[i] Create directory: /srv/www/default, copy default HTML files"
  mkdir -p /srv/www/default
  cp -rf /etc/nginx/default/* /srv/www/default/
fi

if [ ! -d /srv/conf/nginx ]; then
  echo "[i] Create directory: /srv/conf/nginx, copy default Ningx config files"
  mkdir -p /srv/conf/nginx
  cp /etc/nginx/nginx.conf /srv/conf/nginx/
  cp /etc/nginx/mime.types /srv/conf/nginx/
  cp -rf /etc/nginx/conf.d /srv/conf/nginx/
fi

echo "[i] Start nginx with parameter: $@"
exec "$@"
