#!/bin/bash

NODE=desmond
echo "$NODE" > /etc/hostname
hostname "$NODE"
grep -q "127.0.1.1 $NODE" /etc/hosts || echo "127.0.1.1 $NODE" >> /etc/hosts

echo "nameserver 192.168.122.1" > /etc/resolv.conf
[ -x /usr/sbin/apache2 ] || {
  apt-get update
  apt-get install apache2 -y
}

mkdir -p /arsip
echo "Halo dari Arsip $NODE" > /arsip/info.txt
echo "Dokumen rahasia 1" > /arsip/dokumen1.txt

cat > /etc/apache2/sites-available/000-default.conf <<'EOF'
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /arsip/

    <Directory /arsip/>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

service apache2 restart

cat > /etc/resolv.conf <<EOT
nameserver 10.84.1.2
nameserver 10.84.1.3
nameserver 192.168.122.1
EOT
