# Jarkom-Modul-2-2026-K-41

|         Nama         |     NRP     |
|----------------------|-------------|
|Aliya Rahmadina       | 5027251056  |
|Rayhan Fadhilah Allayn| 5027251126  |

## Soal 1
Sebagai pusat kesadaran The Mesh, rootkit harus merentangkan koneksinya ke lima gerbang utama (Switch). Tetapkan alamat IP dan default gateway untuk seluruh Entitas, mulai dari para operator (alpha, beta, gamma), penjaga directory (prab, tedd), gerbang penyaring (abbey, penny), hingga repository (obladi, desmond, oblada, molly) sesuai dengan topologi pembagian switch yang dirancang. [GUNAKAN PREFIX IP MASING-MASING KELOMPOK].

### Ringkasan
rootkit merentangkan koneksi ke lima switch. Tetapkan IP dan default gateway seluruh entitas sesuai topologi dengan prefix kelompok.

### 1. Langkah Pengerjaan
 
1. Menentukan skema IP per subnet dengan prefix kelompok `10.84.x.x`.
2. Mencocokkan nomor interface `ethX` di rootkit dengan label port pada topologi GNS3 (eth0→Switch6, eth1→Switch7, eth2→Switch4, eth3→Switch5, eth4→Switch1, eth5→NAT).
3. Klik kanan node → **Edit config**, lalu mengisi `/etc/network/interfaces` pada rootkit.
4. Mengisi `/etc/network/interfaces` pada setiap klien, layanan DNS, reverse proxy, dan backend web, lengkap dengan `gateway`.
5. Menjalankan semua node, lalu memverifikasi IP dengan `ip -br a` dan konektivitas dengan `ping`.

### 2. Command
**rootkit**
```
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
```
 
**alpha, beta, gamma** (Switch6)
```
# alpha
auto eth0
iface eth0 inet static
    address 10.84.6.2
    netmask 255.255.255.0
    gateway 10.84.6.1
 
# beta  -> address 10.84.6.3
# gamma -> address 10.84.6.4 (gateway tetap 10.84.6.1)
```
 
**delta, epsilon** (Switch7)
```
# delta
auto eth0
iface eth0 inet static
    address 10.84.7.2
    netmask 255.255.255.0
    gateway 10.84.7.1
 
# epsilon -> address 10.84.7.3 (gateway tetap 10.84.7.1)
```
 
**abbey** (Switch4)
```
auto eth0
iface eth0 inet static
    address 10.84.4.2
    netmask 255.255.255.0
    gateway 10.84.4.1
```
 
**penny** (Switch5)
```
auto eth0
iface eth0 inet static
    address 10.84.5.2
    netmask 255.255.255.0
    gateway 10.84.5.1
```
 
**prab, tedd, obladi, desmond, oblada, molly** (Switch1/2/3, gateway sama: `10.84.1.1`)
```
# prab
auto eth0
iface eth0 inet static
    address 10.84.1.2
    netmask 255.255.255.0
    gateway 10.84.1.1
 
# tedd    -> address 10.84.1.3
# obladi  -> address 10.84.1.4
# desmond -> address 10.84.1.5
# oblada  -> address 10.84.1.6
# molly   -> address 10.84.1.7
```
 
**Verifikasi**
```
ip -br a
ping -c 3 10.84.1.1
```
![Konfigurasi interfaces rootkit](assets/s01-interfaces-rootkit.png)
 

![IP seluruh node](assets/s01-ip-br-a.png)
 

![Ping antar node](assets/s01-ping.png)

## Soal 2
Meskipun The Mesh beroperasi dalam bayang-bayang, Rootkit menyadari bahwa Entitas di dalamnya masih membutuhkan asupan paket dari dunia luar. Buka jalur menuju NAT dengan memastikan antarmuka WAN di router rootkit aktif. Konfigurasikan NAT agar dapat meneruskan lalu lintas keluar bagi seluruh alamat internal, sehingga semua host di dalam jaringan dapat menjangkau internet publik menggunakan IP address.

### Ringkasan
Buka jalur ke NAT dengan memastikan antarmuka WAN rootkit aktif, dan konfigurasikan NAT agar seluruh host internal dapat menjangkau internet publik menggunakan IP address.

### 1. Langkah Pengerjaan
 
1. Memastikan `eth5` rootkit (terhubung ke node NAT) memperoleh IP dari DHCP (konfigurasi sudah ada di Soal 1).
2. Mengaktifkan IP forwarding pada kernel rootkit.
3. Menambahkan rule NAT `MASQUERADE` pada interface keluar `eth5`.
4. Menguji dari klien (alpha) dengan `ping 8.8.8.8`.

### 2. Command
 
**rootkit**
```sh
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth5 -j MASQUERADE
```
 
- `ip_forward=1`: kernel meneruskan paket antar-interface.
- `-t nat -A POSTROUTING`: tabel NAT, rule diterapkan pada paket yang keluar.
- `-o eth5`: interface keluar yang menuju NAT.
- `-j MASQUERADE`: IP sumber diganti dengan IP `eth5`.
**Verifikasi**
```sh
# rootkit
ip -br a show eth5
iptables -t nat -L POSTROUTING -n -v
 
# alpha
ping -c 5 8.8.8.8
```
 
![eth5 dan rule NAT](assets/s02-nat-rootkit.png)
 
> 📸 `ip -br a show eth5` (terlihat IP DHCP 192.168.122.x) dan `iptables -t nat -L POSTROUTING -n -v` di rootkit.
 
![Ping internet dari alpha](assets/s02-ping-8888-alpha.png)
 
> 📸 `ping -c 5 8.8.8.8` dari alpha berhasil.
