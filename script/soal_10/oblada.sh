rm -f /var/www/html/index.nginx-debian.html

cat > /var/www/html/index.php <<'EOF'
<?php
echo "<h1>Selamat Datang di Beranda Core</h1>";
echo "<p>Ini adalah halaman utama di node " . gethostname() . ".</p>";
echo "<a href='profil'>Lihat Profil</a>";
?>
EOF

cat > /var/www/html/profil.php <<'EOF'
<?php
echo "<h1>Halaman Profil</h1>";
echo "<p>Nama Node: " . gethostname() . "</p>";
echo "<p>Layanan web dinamis PHP-FPM berjalan sempurna (Clean URL aktif).</p>";
echo "<a href='/'>Kembali ke Beranda</a>";
?>
EOF

cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.php index.html index.htm;
    server_name _;

    # Clean URL: /profil -> /profil.php
    rewrite ^/profil$ /profil.php last;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/phpPHPVER-fpm.sock;
    }
}
EOF
sed -i "s/PHPVER/$PHPV/" /etc/nginx/sites-available/default

service php${PHPV}-fpm restart
service nginx restart
