#!/bin/bash

[ -x /usr/sbin/nginx ] || {
  apt-get update
  apt-get install nginx -y
}

mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled

cat > /etc/nginx/sites-available/redirect-abbey <<'EOF'
server {
    listen 80;
    server_name abbey.k41.com 10.84.4.2;

    return 302 http://static.k41.com$request_uri;
}
EOF

ln -sf /etc/nginx/sites-available/redirect-abbey /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
service nginx restart
