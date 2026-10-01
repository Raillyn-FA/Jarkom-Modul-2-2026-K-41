#!/bin/bash

mkdir -p /var/www/admin

echo "Ruang Rahasia Sindikat - Area Admin" > /var/www/admin/index.html

htpasswd -bc /etc/apache2/.htpasswd prabs "pakar_pinter_jadi_gob***"

cat >> /etc/apache2/sites-available/000-default.conf <<'EOF'

<Directory /var/www/admin>
    AuthType Basic
    AuthName "Area Rahasia Sindikat"
    AuthUserFile /etc/apache2/.htpasswd
    Require valid-user
    Options Indexes FollowSymLinks
    AllowOverride None
</Directory>

EOF

apache2ctl configtest
service apache2 restart
