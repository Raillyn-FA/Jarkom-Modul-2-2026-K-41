#!/bin/bash

mkdir -p /var/www/orion

cat <<'EOF' > /var/www/orion/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Orion</title>
</head>
<body>
    <h1>Orion Static Page di Abbey</h1>
</body>
</html>
EOF

mkdir -p /etc/nginx/snippets

cat > /etc/nginx/snippets/orion.conf <<'EOF'
location /orion {
    alias /var/www/orion/;
    index index.html index.htm;
    try_files $uri $uri/ =404;
}
EOF

sed -i '/server_name/a\    include /etc/nginx/snippets/orion.conf;' /etc/nginx/sites-available/redirect-abbey

nginx -t

service nginx restart
