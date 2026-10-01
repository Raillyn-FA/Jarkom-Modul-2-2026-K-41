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

cat > /etc/bind/jarkom/k41.com <<'EOF'
$TTL 604800
@   IN  SOA prab.k41.com. root.k41.com. (
        2026100101 ; Serial
        604800     ; Refresh
        86400      ; Retry
        2419200    ; Expire
        604800 )   ; Negative Cache TTL
@   IN  NS  prab.k41.com.
@   IN  NS  tedd.k41.com.
@        IN  A      10.84.5.2
prab     IN  A      10.84.1.2
tedd     IN  A      10.84.1.3
EOF

cat > /etc/resolv.conf <<EOT
nameserver 10.84.1.2
nameserver 10.84.1.3
nameserver 192.168.122.1
EOT
