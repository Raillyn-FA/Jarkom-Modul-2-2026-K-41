#!/bin/bash
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# 1. Aktifkan modul Apache yang diperlukan
a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers rewrite
a2dissite 000-default

# 2. Buat file VirtualHost Reverse Proxy untuk penny
cat << 'EOF' > /etc/apache2/sites-available/010-penny-www.conf

    ServerName www.k41.com
    ProxyPreserveHost On
    RequestHeader set X-Real-IP "expr=%{REMOTE_ADDR}"

    
        BalancerMember http://10.84.1.4:80 route=obladi
        BalancerMember http://10.84.1.5:80 route=desmond
        ProxySet lbmethod=byrequests
    

    ProxyPass "/" balancer://vault/
    ProxyPassReverse "/" balancer://vault/

EOF

# 3. Aktifkan site dan restart Apache
a2ensite 010-penny-www.conf
service apache2 restart
