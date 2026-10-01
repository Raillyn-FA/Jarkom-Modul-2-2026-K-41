!/bin/bash

NODE=prab
echo "$NODE" > /etc/hostname
hostname "$NODE"
grep -q "127.0.1.1 $NODE" /etc/hosts || echo "127.0.1.1 $NODE" >> /etc/hosts

# Resolver sementara supaya apt bisa jalan (DNS internal belum hidup)
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
zone "1.84.10.in-addr.arpa" {
    type master;
    file "/etc/bind/jarkom/1.84.10.rev";
    allow-transfer { 10.84.1.3; };
    notify yes;
};
zone "4.84.10.in-addr.arpa" {
    type master;
    file "/etc/bind/jarkom/4.84.10.rev";
    allow-transfer { 10.84.1.3; };
    notify yes;
};
zone "5.84.10.in-addr.arpa" {
    type master;
    file "/etc/bind/jarkom/5.84.10.rev";
    allow-transfer { 10.84.1.3; };
    notify yes;
};
EOF

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
rootkit  IN  A      10.84.1.1
alpha    IN  A      10.84.6.2
beta     IN  A      10.84.6.3
gamma    IN  A      10.84.6.4
delta    IN  A      10.84.7.2
epsilon  IN  A      10.84.7.3
abbey    IN  A      10.84.4.2
penny    IN  A      10.84.5.2
obladi   IN  A      10.84.1.4
desmond  IN  A      10.84.1.5
oblada   IN  A      10.84.1.6
molly    IN  A      10.84.1.7
vault    IN  A      10.84.1.4
vault    IN  A      10.84.1.5
core     IN  A      10.84.1.6
core     IN  A      10.84.1.7
www      IN  CNAME  penny.k41.com.
static   IN  CNAME  abbey.k41.com.
EOF

cat > /etc/bind/jarkom/1.84.10.rev <<'EOF'
$TTL 604800
@   IN  SOA prab.k41.com. root.k41.com. (
        2026100101 ; Serial
        604800     ; Refresh
        86400      ; Retry
        2419200    ; Expire
        604800 )   ; Negative Cache TTL
@   IN  NS  prab.k41.com.
@   IN  NS  tedd.k41.com.
2   IN  PTR  prab.k41.com.
3   IN  PTR  tedd.k41.com.
4   IN  PTR  obladi.k41.com.
5   IN  PTR  desmond.k41.com.
6   IN  PTR  oblada.k41.com.
7   IN  PTR  molly.k41.com.
EOF

cat > /etc/bind/jarkom/4.84.10.rev <<'EOF'
$TTL 604800
@   IN  SOA prab.k41.com. root.k41.com. (
        2026100101 ; Serial
        604800     ; Refresh
        86400      ; Retry
        2419200    ; Expire
        604800 )   ; Negative Cache TTL
@   IN  NS  prab.k41.com.
@   IN  NS  tedd.k41.com.
2   IN  PTR  abbey.k41.com.
EOF

cat > /etc/bind/jarkom/5.84.10.rev <<'EOF'
$TTL 604800
@   IN  SOA prab.k41.com. root.k41.com. (
        2026100101 ; Serial
        604800     ; Refresh
        86400      ; Retry
        2419200    ; Expire
        604800 )   ; Negative Cache TTL
@   IN  NS  prab.k41.com.
@   IN  NS  tedd.k41.com.
2   IN  PTR  penny.k41.com.
EOF

named-checkconf && service named restart

cat > /etc/resolv.conf <<EOT
nameserver 10.84.1.2
nameserver 10.84.1.3
nameserver 192.168.122.1
EOT
