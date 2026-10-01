auto eth0
iface eth0 inet static
    address 10.84.6.2
    netmask 255.255.255.0
    gateway 10.84.6.1

    #untuk soal 3
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
