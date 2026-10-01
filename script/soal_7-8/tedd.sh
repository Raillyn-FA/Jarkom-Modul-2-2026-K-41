#!/bin/bash

NODE=tedd
echo "$NODE" > /etc/hostname
hostname "$NODE"
grep -q "127.0.1.1 $NODE" /etc/hosts || echo "127.0.1.1 $NODE" >> /etc/hosts

echo "nameserver 192.168.122.1" > /etc/resolv.conf
[ -x /usr/sbin/named ] || {
  apt-get update
  apt-get install bind9 dnsutils -y
}

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
    type slave;
    masters { 10.84.1.2; };
    file "/var/lib/bind/k41.com";
};
zone "1.84.10.in-addr.arpa" {
    type slave;
    masters { 10.84.1.2; };
    file "/var/lib/bind/1.84.10.rev";
};
zone "4.84.10.in-addr.arpa" {
    type slave;
    masters { 10.84.1.2; };
    file "/var/lib/bind/4.84.10.rev";
};
zone "5.84.10.in-addr.arpa" {
    type slave;
    masters { 10.84.1.2; };
    file "/var/lib/bind/5.84.10.rev";
};
EOF

named-checkconf && service named restart

cat > /etc/resolv.conf <<EOT
nameserver 10.84.1.2
nameserver 10.84.1.3
nameserver 192.168.122.1
EOT
