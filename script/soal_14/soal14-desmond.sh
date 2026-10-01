#!/bin/bash

cat > /etc/apache2/conf-available/custom-log.conf <<'EOF'
LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" proxytext
CustomLog ${APACHE_LOG_DIR}/access.log proxytext
EOF

a2enconf custom-log
apache2ctl configtest
service apache2 restart

