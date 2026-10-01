#!/bin/bash

cat > /etc/apache2/sites-available/redirect-penny.conf <<'EOF'
<VirtualHost *:80>
    ServerName penny.k41.com
    ServerAlias 10.84.5.2

    Redirect 301 / http://www.k41.com/
</VirtualHost>
EOF

a2ensite redirect-penny.conf
apache2ctl configtest
service apache2 restart
