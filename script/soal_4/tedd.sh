#!/bin/bash

echo "nameserver 192.168.122.1" > /etc/resolv.conf
[ -x /usr/sbin/named ] || {
  apt-get update
  apt-get install bind9 dnsutils -y
}

mkdir -p /etc/bind/jarkom

cat > /etc/bind/named.conf.options <<'EOF'
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    allow-query { any; };
    dnssec-validation auto;
    listen-on-v6 { any; };
};
EOF

cat > /etc/bind/named.conf.local <<'EOF'
zone "k41.com" {
    type master;
    file "/etc/bind/jarkom/k41.com";
    allow-transfer { 10.84.1.3; };
    notify yes;
};
EOF

cat > /etc/resolv.conf <<EOT
nameserver 10.84.1.2
nameserver 10.84.1.3
nameserver 192.168.122.1
EOT
