auto lo
iface lo inet loopback

auto eth5
iface eth5 inet dhcp

auto eth0
iface eth0 inet static
    address 10.84.6.1
    netmask 255.255.255.0

auto eth1
iface eth1 inet static
    address 10.84.7.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 10.84.4.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 10.84.5.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 10.84.1.1
    netmask 255.255.255.0
