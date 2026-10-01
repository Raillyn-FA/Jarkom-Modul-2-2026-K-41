#!/bin/bash

sed -i '/proxy_ip/d' /etc/nginx/nginx.conf

cat << 'EOF' > /tmp/log_patch.txt
    log_format proxy_ip '\(http_x_forwarded_for -\)remote_user [\(time_local] "\)request" \(status\)body_bytes_sent "\(http_referer" "\)http_user_agent"';
EOF

sed -i '/http {/r /tmp/log_patch.txt' /etc/nginx/nginx.conf

sed -i 's|access_log /var/log/nginx/access.log;|access_log /var/log/nginx/access.log proxy_ip;|' /etc/nginx/sites-available/default

nginx -t
service nginx restart

