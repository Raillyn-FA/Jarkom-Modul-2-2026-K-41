#!/bin/bash

mkdir -p /var/www/eternal

cat <<'EOF' > /var/www/eternal/index.php
<?php
echo "Eternal PHP Rendered Successfully di Penny";
echo "<br>Hostname: " . gethostname();
?>
EOF

cat >> /etc/apache2/sites-available/000-default.conf <<'EOF'

Alias /eternal /var/www/eternal/

<Directory /var/www/eternal/>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>

<FilesMatch "\.php$">
    SetHandler "proxy:unix:/run/php/php-fpm.sock|fcgi://localhost"
</FilesMatch>

EOF

apache2ctl configtest

service apache2 restart
