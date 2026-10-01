#!/bin/bash
# SOAL 10 (JALANKAN DI oblada DAN molly): Nginx + PHP-FPM, halaman beranda & /profil (URL bersih)
set -e
apt-get update -y
apt-get install -y nginx php-fpm

# versi PHP otomatis (di Debian trixie = 8.4)
PHPV=$(ls /etc/php | sort -V | tail -1)
SOCK="/run/php/php${PHPV}-fpm.sock"
echo "PHP terdeteksi: ${PHPV}  socket: ${SOCK}"

mkdir -p /var/www/html
cat > /var/www/html/index.php <<'EOF'
<?php
echo "<h1>Beranda - Area Core</h1>";
echo "<p>Dilayani oleh node: <b>" . gethostname() . "</b></p>";
echo "<p><a href=\"/profil\">Lihat profil</a></p>";
EOF
cat > /var/www/html/profil.php <<'EOF'
<?php
echo "<h1>Profil - Area Core</h1>";
echo "<p>Dilayani oleh node: <b>" . gethostname() . "</b></p>";
echo "<p>PHP " . phpversion() . "</p>";
EOF

rm -f /etc/nginx/sites-enabled/default
cat > /etc/nginx/sites-available/core.conf <<EOF
server {
    listen 80 default_server;
    server_name _;

    root /var/www/html;
    index index.php index.html;

    # URL bersih: /profil -> /profil.php
    rewrite ^/profil\$ /profil.php last;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:${SOCK};
    }
}
EOF
ln -sf /etc/nginx/sites-available/core.conf /etc/nginx/sites-enabled/core.conf

service php${PHPV}-fpm restart || service php${PHPV}-fpm start
nginx -t
service nginx restart
echo; echo "UJI: curl -s http://localhost/   |   curl -s http://localhost/profil"
