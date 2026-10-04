# Jarkom-Modul-2-2026-K-41

|         Nama         |     NRP     |
|----------------------|-------------|
|Aliya Rahmadina       | 5027251056  |
|Rayhan Fadhilah Allayn| 5027251126  |

## Soal 1
Sebagai pusat kesadaran The Mesh, rootkit harus merentangkan koneksinya ke lima gerbang utama (Switch). Tetapkan alamat IP dan default gateway untuk seluruh Entitas, mulai dari para operator (alpha, beta, gamma), penjaga directory (prab, tedd), gerbang penyaring (abbey, penny), hingga repository (obladi, desmond, oblada, molly) sesuai dengan topologi pembagian switch yang dirancang. [GUNAKAN PREFIX IP MASING-MASING KELOMPOK].

### Ringkasan
*Rootkit merentangkan koneksi ke lima switch. Tetapkan IP dan default gateway seluruh entitas sesuai topologi dengan prefix kelompok.*

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

---

## Soal 2
Meskipun The Mesh beroperasi dalam bayang-bayang, Rootkit menyadari bahwa Entitas di dalamnya masih membutuhkan asupan paket dari dunia luar. Buka jalur menuju NAT dengan memastikan antarmuka WAN di router rootkit aktif. Konfigurasikan NAT agar dapat meneruskan lalu lintas keluar bagi seluruh alamat internal, sehingga semua host di dalam jaringan dapat menjangkau internet publik menggunakan IP address.

### Ringkasan
*Buka jalur ke NAT dengan memastikan antarmuka WAN rootkit aktif, dan konfigurasikan NAT agar seluruh host internal dapat menjangkau internet publik menggunakan IP address.*

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
---

## Soal 3
Jaringan rahasia tidak akan berfungsi tanpa sinkronisasi antar divisi. Pastikan seluruh Entitas dapat saling terhubung dan berkomunikasi lintas jalur (routing internal via rootkit berfungsi). Untuk menghindari fragmentasi saat persiapan, pastikan setiap host non-router menambahkan resolver 192.168.122.1 (tambah di file /etc/resolv.conf, kalau sudah pakai resolver itu tidak perlu memasukkan resolver google) saat antarmukanya aktif agar akses untuk mengunduh paket instalasi dari internet tersedia sejak awal beroperasi.

### Ringkasan 
*Pastikan seluruh entitas dapat saling terhubung lintas jalur (routing internal via rootkit). Setiap host non-router menambahkan resolver `192.168.122.1` saat antarmuka aktif agar bisa mengunduh paket sejak awal.*
 
### 1. Langkah Pengerjaan
 
1. Memastikan IP forwarding rootkit aktif (Soal 2). Karena seluruh subnet terhubung langsung ke rootkit, routing antar-subnet berjalan tanpa static route tambahan.
2. Menambahkan baris `up` pada `/etc/network/interfaces` setiap host non-router, sehingga `nameserver 192.168.122.1` tertulis ke `/etc/resolv.conf` setiap interface naik.
3. Menguji `ping` lintas subnet dan `ping google.com`.
### 2. Command
 
Tambahan pada blok `eth0` **setiap host non-router** (contoh alpha):
```
auto eth0
iface eth0 inet static
    address 10.84.6.2
    netmask 255.255.255.0
    gateway 10.84.6.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```
 
**Verifikasi**
```sh
sysctl net.ipv4.ip_forward          # di rootkit
cat /etc/resolv.conf                # di alpha
ping -c 3 10.84.7.2                 # alpha -> delta
ping -c 3 10.84.1.7                 # alpha -> molly
ping -c 3 google.com                # alpha -> internet via nama
```
 
> Catatan: pada Soal 4 urutan resolver diganti menjadi prab → tedd → 192.168.122.1. Baris `up` di atas hanya dipakai sampai tahap DNS internal hidup, karena akan menimpa urutan resolver yang baru. Lihat Soal 4 dan Soal 20.
 
![resolv.conf alpha](assets/s03-resolv-alpha.png)
 
> 📸 `cat /etc/resolv.conf` di alpha berisi `nameserver 192.168.122.1`.
 
![Ping lintas subnet](assets/s03-ping-lintas-subnet.png)
 
> 📸 Ping lintas subnet dari minimal dua node berbeda (mis. alpha→delta, alpha→molly, penny→abbey) dan `ping -c 3 google.com`.

---

## Soal 4
Penjaga Direktori mulai menuliskan hukum The Mesh. Pada node prab, bangun zona <xxxx>.com sebagai authoritative dengan SOA yang menunjuk ke prab.<xxxx>.com, serta tambahkan catatan NS untuk prab.<xxxx>.com dan tedd.<xxxx>.com. Buat A record untuk prab.<xxxx>.com dan tedd.<xxxx>.com yang mengarah ke alamat IP mereka masing-masing, serta A record apex <xxxx>.com yang mengarah ke gerbang aplikasi dinamis (penny). Aktifkan fitur notify dan allow-transfer ke tedd, lalu set forwarders ke 192.168.122.1. Di node tedd, tarik zona <xxxx>.com dari master dan pastikan server menjawab secara authoritative. Setelah fondasi nama ini berdiri kokoh, perbarui urutan resolver pada seluruh Entitas non-router menjadi: IP prab, IP tedd, lalu 192.168.122.1. Verifikasi bahwa query ke domain apex maupun hostname di dalam zona dijawab dengan benar oleh prab atau tedd. 

### Ringkasan
*Pada prab bangun zona `k41.com` sebagai authoritative (SOA ke `prab.k41.com`), NS untuk prab dan tedd, A record prab, tedd, dan apex ke penny. Aktifkan `notify`, `allow-transfer` ke tedd, `forwarders` ke `192.168.122.1`. Di tedd tarik zona dari master dan pastikan menjawab authoritative. Lalu ubah urutan resolver semua non-router menjadi prab → tedd → 192.168.122.1.*
 
### 1. Langkah Pengerjaan
 
1. Pada prab dan tedd: memasang `bind9` dan `dnsutils` (resolver sementara dari Soal 3 diperlukan agar `apt-get` berjalan). Di image ini nama service adalah `named`.
2. Pada prab: menulis `named.conf.options` (forwarders), `named.conf.local` (zona master, `allow-transfer`, `notify`), dan file zona `/etc/bind/jarkom/k41.com`.
3. Pada tedd: menulis `named.conf.options` dan `named.conf.local` dengan zona bertipe `slave` yang menunjuk ke master prab.
4. Memvalidasi dengan `named-checkconf` dan `named-checkzone`, lalu `service named restart` di prab terlebih dahulu, kemudian di tedd.
5. Mengubah `/etc/resolv.conf` seluruh node non-router menjadi urutan prab → tedd → 192.168.122.1.
6. Memverifikasi jawaban DNS dari prab dan tedd, termasuk flag `aa`.
### 2. Command
 
**prab dan tedd** — instalasi
```sh
apt-get update
apt-get install bind9 dnsutils -y
```
 
**prab** — `/etc/bind/named.conf.options`
```
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    allow-query { any; };
    dnssec-validation auto;
    listen-on-v6 { any; };
};
```
 
**prab** — `/etc/bind/named.conf.local`
```
zone "k41.com" {
    type master;
    file "/etc/bind/jarkom/k41.com";
    allow-transfer { 10.84.1.3; };
    notify yes;
};
```
 
**prab** — `/etc/bind/jarkom/k41.com` (`mkdir -p /etc/bind/jarkom` dahulu)
```
$TTL 604800
@   IN  SOA prab.k41.com. root.k41.com. (
        2026093001 ; Serial
        604800     ; Refresh
        86400      ; Retry
        2419200    ; Expire
        604800 )   ; Negative Cache TTL
@       IN  NS  prab.k41.com.
@       IN  NS  tedd.k41.com.
@       IN  A   10.84.5.2
prab    IN  A   10.84.1.2
tedd    IN  A   10.84.1.3
```
Apex `k41.com` mengarah ke penny (`10.84.5.2`), sesuai bunyi soal.
 
**tedd** — `/etc/bind/named.conf.options` (sama dengan prab)
 
**tedd** — `/etc/bind/named.conf.local`
```
zone "k41.com" {
    type slave;
    masters { 10.84.1.2; };
    file "/var/lib/bind/k41.com";
};
```
 
**Validasi dan restart**
```sh
# prab
named-checkconf
named-checkzone k41.com /etc/bind/jarkom/k41.com
service named restart
 
# tedd
named-checkconf
service named restart
```
 
**Semua node non-router** — urutan resolver baru
```sh
cat > /etc/resolv.conf <<EOT
nameserver 10.84.1.2
nameserver 10.84.1.3
nameserver 192.168.122.1
EOT
```
 
**Verifikasi** (dari alpha)
```sh
host k41.com 10.84.1.2
host prab.k41.com 10.84.1.3
dig @10.84.1.2 k41.com SOA
dig @10.84.1.3 k41.com SOA      # cari flag "aa" pada baris flags
```
 
![named.conf prab](assets/s04-conf-prab.png)
 
> 📸 `cat /etc/bind/named.conf.local` dan `named.conf.options` di prab.
 
![Zona k41.com](assets/s04-zone-prab.png)
 
> 📸 Isi `/etc/bind/jarkom/k41.com` dan hasil `named-checkzone ... OK`.
 
![named.conf tedd](assets/s04-conf-tedd.png)
 
> 📸 `cat /etc/bind/named.conf.local` di tedd (zona slave).
 
![Resolver alpha](assets/s04-resolv-alpha.png)
 
> 📸 `cat /etc/resolv.conf` di alpha berisi urutan prab → tedd → 192.168.122.1.
 
![Query DNS ke prab dan tedd](assets/s04-host-prab-tedd.png)
 
> 📸 `host k41.com 10.84.1.2` dan `host prab.k41.com 10.84.1.3`.
 
![Authoritative dari tedd](assets/s04-dig-aa-tedd.png)
 
> 📸 `dig @10.84.1.3 k41.com SOA` dengan flag `aa` terlihat jelas.
 
---
 
## Soal 5
"Entitas tanpa identitas adalah anomali," pesan Rootkit. Namai semua Entitas (hostname) sesuai glosarium: rootkit, alpha, beta, gamma, delta, epsilon, prab, tedd, abbey, penny, obladi, desmond, oblada, molly, dan verifikasi bahwa setiap host mengenali hostname tersebut secara system-wide. Buat setiap domain untuk masing-masing node sesuai dengan namanya (contoh: alpha.<xxxx>.com) dan assign IP masing-masing juga. Lakukan pengecualian untuk node yang bertanggung jawab atas prab dan tedd.

### Ringkasan
*Namai semua entitas (hostname) sesuai glosarium dan verifikasi dikenali system-wide. Buat domain untuk tiap node (contoh `alpha.k41.com`) beserta IP-nya, kecuali prab dan tedd.*
 
### 1. Langkah Pengerjaan
 
1. Mengatur hostname di seluruh 14 node (`/etc/hostname` dan `hostname`).
2. Menambahkan entri `127.0.1.1 <nama>` pada `/etc/hosts` agar hostname dikenali system-wide.
3. Menambahkan A record semua node (kecuali prab dan tedd yang sudah ada di Soal 4) pada zona di prab, menaikkan serial SOA.
4. Restart `named` di prab lalu tedd, kemudian menguji resolusi dari klien.
### 2. Command
 
**Semua node** (ganti `<nama>`: rootkit, alpha, beta, gamma, delta, epsilon, prab, tedd, abbey, penny, obladi, desmond, oblada, molly)
```sh
echo "<nama>" > /etc/hostname
hostname <nama>
grep -q "127.0.1.1 <nama>" /etc/hosts || echo "127.0.1.1 <nama>" >> /etc/hosts
```
 
**prab** — tambahan di `/etc/bind/jarkom/k41.com` (serial dinaikkan menjadi `2026093002`)
```
rootkit  IN  A  10.84.1.1
alpha    IN  A  10.84.6.2
beta     IN  A  10.84.6.3
gamma    IN  A  10.84.6.4
delta    IN  A  10.84.7.2
epsilon  IN  A  10.84.7.3
abbey    IN  A  10.84.4.2
penny    IN  A  10.84.5.2
obladi   IN  A  10.84.1.4
desmond  IN  A  10.84.1.5
oblada   IN  A  10.84.1.6
molly    IN  A  10.84.1.7
```
 
```sh
named-checkzone k41.com /etc/bind/jarkom/k41.com
service named restart     # prab, lalu tedd
```
 
**Verifikasi**
```sh
hostname
ping -c 1 $(hostname)
host alpha.k41.com
ping -c 3 molly.k41.com        # dari alpha
```
 
![Hostname tiap node](assets/s05-hostname.png)
 
> 📸 Output `hostname` dan `cat /etc/hosts` dari beberapa node (idealnya semua 14, boleh digabung per segmen).
 
![Zona setelah ditambah](assets/s05-zone-prab.png)
 
> 📸 Isi `/etc/bind/jarkom/k41.com` setelah A record ditambah, beserta serial `2026093002`.
 
![Resolusi hostname](assets/s05-host-ping.png)
 
> 📸 `host alpha.k41.com` dan `ping -c 3 molly.k41.com` dari alpha.
 
---
 
## Soal 6
Pastikan zone transfer berjalan, pastikan tedd telah menerima salinan zona terbaru dari prab. Nilai serial SOA di keduanya harus sama karena keduanya tidak bisa dipisahkan dan saling melengkapi.

### Ringkasan 
*Pastikan zone transfer berjalan dan tedd menerima salinan zona terbaru dari prab. Serial SOA di keduanya harus sama.*
 
### 1. Langkah Pengerjaan
 
1. Memastikan serial SOA pada prab sudah naik setiap file zona berubah.
2. Restart `named` di prab lalu di tedd supaya tedd menarik zona terbaru melalui `notify` dan `allow-transfer`.
3. Membandingkan serial SOA dari kedua server dengan `host -t SOA`.
### 2. Command
 
```sh
host -t SOA k41.com 10.84.1.2     # prab
host -t SOA k41.com 10.84.1.3     # tedd
```
 
Jika serial berbeda: naikkan serial di prab, `service named restart` di prab, lalu `service named restart` di tedd.
 
Hasil yang diharapkan: kedua perintah menampilkan SOA dengan serial yang sama (`2026093002` pada tahap ini).
 
![Serial SOA prab dan tedd](assets/s06-soa-serial.png)
 
> 📸 Kedua perintah `host -t SOA` berdampingan, serial terlihat sama.
 
![File zona di tedd](assets/s06-tedd-zone-file.png)
 
> 📸 `ls -l /var/lib/bind/` di tedd yang menunjukkan file zona hasil transfer.
 
---
 
## Soal 7
abbey dan penny sebagai gerbang utama, obladi dan desmond sebagai web statis, oblada dan molly sebagai web dinamis. Tambahkan pada zona <xxxx>.com A record untuk vault.<xxxx>.com (IP obladi & desmond), dan core.<xxxx>.com (IP oblada & molly). Tetapkan CNAME:

- www.<xxxx>.com → penny.<xxxx>.com
- static.<xxxx>.com → abbey.<xxxx>.com

Verifikasi dari dua klien berbeda bahwa seluruh hostname tersebut ter-resolve ke tujuan yang benar dan konsisten.


### Ringkasan 
*Tambahkan A record `vault.k41.com` (IP obladi dan desmond) dan `core.k41.com` (IP oblada dan molly). CNAME: `www` → `penny` dan `static` → `abbey`. Verifikasi dari dua klien berbeda.*
 
### 1. Langkah Pengerjaan
 
1. Menambahkan record `vault` (dua A record, round robin), `core` (dua A record), serta dua CNAME pada zona di prab.
2. Menaikkan serial SOA menjadi `2026093003`.
3. Validasi dengan `named-checkzone`, restart `named` di prab lalu tedd.
4. Menguji resolusi dari **dua klien berbeda** (alpha dan beta).
### 2. Command
 
**prab** — tambahan di `/etc/bind/jarkom/k41.com`
```
vault   IN  A      10.84.1.4
vault   IN  A      10.84.1.5
core    IN  A      10.84.1.6
core    IN  A      10.84.1.7
www     IN  CNAME  penny.k41.com.
static  IN  CNAME  abbey.k41.com.
```
 
```sh
named-checkzone k41.com /etc/bind/jarkom/k41.com
service named restart     # prab, lalu tedd
```
 
**Verifikasi** (jalankan di alpha dan di beta)
```sh
host vault.k41.com
host core.k41.com
host www.k41.com
host static.k41.com
```
 
Hasil yang diharapkan: `vault` → 10.84.1.4 dan 10.84.1.5; `core` → 10.84.1.6 dan 10.84.1.7; `www` alias penny (10.84.5.2); `static` alias abbey (10.84.4.2).
 
![Verifikasi dari alpha](assets/s07-host-alpha.png)
 
> 📸 Keempat perintah `host` dijalankan di **alpha**.
 
![Verifikasi dari beta](assets/s07-host-beta.png)
 
> 📸 Keempat perintah `host` dijalankan di **beta** (klien berbeda).
 
---
 
## Soal 8
Di prab (master) deklarasikan reverse zone untuk segmen jaringan  tempat abbey, penny, area vault, dan area core berada. Di tedd (slave) tarik reverse zone tersebut sebagai slave, isi PTR untuk keempat hostname itu agar pencarian balik IP address mengembalikan hostname yang benar, lalu pastikan query reverse untuk alamat abbey, penny, area vault, dan area core dijawab authoritative.

### Ringkasan 
*Di prab deklarasikan reverse zone untuk segmen tempat abbey, penny, area vault, dan area core. Di tedd tarik sebagai slave. Isi PTR untuk keempatnya dan pastikan query reverse dijawab authoritative.*
 
### 1. Langkah Pengerjaan
 
1. Mengidentifikasi segmen yang dibutuhkan: `10.84.4.0/24` (abbey), `10.84.5.0/24` (penny), dan `10.84.1.0/24` (vault + core), sehingga ada tiga reverse zone.
2. Pada prab: mendeklarasikan tiga zona `in-addr.arpa` bertipe master, lalu membuat tiga file `.rev` berisi PTR. Serial `2026093004`.
3. Pada tedd: mendeklarasikan tiga zona yang sama bertipe slave.
4. Validasi dengan `named-checkzone`, restart `named` di prab **lalu** tedd.
5. Menguji `host <IP>` dan membuktikan jawaban authoritative dengan `dig -x ... @tedd`.
### 2. Command
 
**prab** — tambahan di `/etc/bind/named.conf.local`
```
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
```
 
**prab** — header SOA/NS yang sama untuk ketiga file `.rev`
```
$TTL 604800
@   IN  SOA prab.k41.com. root.k41.com. (
        2026093004 ; Serial
        604800     ; Refresh
        86400      ; Retry
        2419200    ; Expire
        604800 )   ; Negative Cache TTL
@   IN  NS  prab.k41.com.
@   IN  NS  tedd.k41.com.
```
 
**prab** — isi PTR
```
# /etc/bind/jarkom/1.84.10.rev
2   IN  PTR  prab.k41.com.
3   IN  PTR  tedd.k41.com.
4   IN  PTR  obladi.k41.com.
5   IN  PTR  desmond.k41.com.
6   IN  PTR  oblada.k41.com.
7   IN  PTR  molly.k41.com.
 
# /etc/bind/jarkom/4.84.10.rev
2   IN  PTR  abbey.k41.com.
 
# /etc/bind/jarkom/5.84.10.rev
2   IN  PTR  penny.k41.com.
```
 
**tedd** — tambahan di `/etc/bind/named.conf.local`
```
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
```
 
**Validasi dan restart**
```sh
# prab
named-checkconf
named-checkzone 1.84.10.in-addr.arpa /etc/bind/jarkom/1.84.10.rev
named-checkzone 4.84.10.in-addr.arpa /etc/bind/jarkom/4.84.10.rev
named-checkzone 5.84.10.in-addr.arpa /etc/bind/jarkom/5.84.10.rev
service named restart
# tedd
service named restart
```
 
**Verifikasi** (dari klien)
```sh
host 10.84.4.2       # abbey
host 10.84.5.2       # penny
host 10.84.1.4       # obladi
host 10.84.1.5       # desmond
host 10.84.1.6       # oblada
host 10.84.1.7       # molly
dig @10.84.1.3 -x 10.84.4.2      # cari flag "aa"
dig @10.84.1.3 -x 10.84.5.2
dig @10.84.1.3 -x 10.84.1.7
```
 
![Reverse zone di prab](assets/s08-reverse-prab.png)
 
> 📸 `named.conf.local` prab dan isi tiga file `.rev`, serta hasil `named-checkzone`.
 
![Slave reverse di tedd](assets/s08-reverse-tedd.png)
 
> 📸 `named.conf.local` tedd dan `ls -l /var/lib/bind/` (tiga file `.rev` hasil transfer).
 
![Reverse lookup](assets/s08-host-reverse.png)
 
> 📸 `host` untuk semua IP: abbey, penny, obladi, desmond, oblada, molly.
 
![Authoritative reverse](assets/s08-dig-aa.png)
 
> 📸 `dig @10.84.1.3 -x ...` dengan flag `aa` terlihat (minimal untuk abbey dan penny).
 
---
 
## Soal 9
Jalankan layanan web statis pada hostname di node area vault (menggunakan apache). Buka folder direktori /arsip/ dan aktifkan fitur autoindex (directory listing) pada konfigurasi Apache sehingga seluruh daftar file di dalamnya dapat ditelusuri langsung dari browser. Akses pengujian harus dilakukan melalui hostname, bukan IP address.

### Ringkasan
*Jalankan web statis di node area vault (obladi dan desmond) menggunakan Apache. Buka folder `/arsip/` dengan autoindex (directory listing). Pengujian lewat hostname, bukan IP.*
 
### 1. Langkah Pengerjaan
 
1. Memasang `apache2` pada obladi dan desmond.
2. Membuat folder `/arsip/` dan beberapa file uji di dalamnya.
3. Mengubah `DocumentRoot` pada `/etc/apache2/sites-available/000-default.conf` menjadi `/arsip/` dan mengaktifkan `Options Indexes`.
4. Restart `apache2`.
5. Menguji dari klien melalui hostname (`obladi.k41.com`, `desmond.k41.com`, `vault.k41.com`).
### 2. Command
 
**obladi dan desmond**
```sh
apt-get update
apt-get install apache2 -y
mkdir -p /arsip/
echo "Halo dari Arsip obladi" > /arsip/info.txt     # di desmond: "Halo dari Arsip desmond"
echo "Dokumen rahasia 1"      > /arsip/dokumen1.txt
```
 
`/etc/apache2/sites-available/000-default.conf`
```apache
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /arsip/
 
    <Directory /arsip/>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
 
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```
 
```sh
service apache2 restart
```
 
> Catatan: saat konfigurasi ditempel ke terminal, karakter `<` dan `>` sempat hilang sehingga muncul error `AllowOverride not allowed here`. Solusinya menulis file lewat heredoc dari script (`cat > file <<'EOF'`) atau base64. Pesan `AH00558 ... fully qualified domain name` hanya peringatan, bukan error.
 
**Verifikasi** (dari alpha)
```sh
curl obladi.k41.com
curl desmond.k41.com
curl vault.k41.com       # round robin: ulangi beberapa kali
```
 
![Konfigurasi Apache](assets/s09-apache-conf.png)
 
> 📸 Isi `000-default.conf` dan `ls /arsip/` di obladi (dan desmond).
 
![curl obladi dan desmond](assets/s09-curl-obladi-desmond.png)
 
> 📸 `curl obladi.k41.com` dan `curl desmond.k41.com` menampilkan halaman `Index of /`.
 
![curl vault](assets/s09-curl-vault.png)
 
> 📸 `curl vault.k41.com` dijalankan beberapa kali, terlihat bergantian (bila perlu bedakan lewat isi `info.txt`).
 
---
 
## Soal 10
Jalankan layanan web dinamis (PHP-FPM) pada hostname di node core (menggunakan nginx). Buat sebuah aplikasi sederhana yang memuat halaman beranda dan halaman profil. Terapkan aturan rewrite pada server sehingga akses ke /profil dapat berfungsi dengan URL bersih (tanpa akhiran .php). Akses pengujian wajib dilakukan melalui hostname.

### Ringkasan
*Jalankan web dinamis (PHP-FPM) di node area core (oblada dan molly) menggunakan Nginx. Buat aplikasi sederhana berisi halaman beranda dan profil. Terapkan rewrite agar `/profil` berfungsi sebagai URL bersih (tanpa `.php`). Pengujian lewat hostname.*
 
### 1. Langkah Pengerjaan
 
1. Memasang `nginx` dan `php-fpm` pada oblada dan molly (versi PHP yang terpasang: 8.4, `php8.4-fpm`).
2. Menghapus halaman bawaan Nginx, lalu membuat `index.php` (beranda) dan `profil.php` (profil) di `/var/www/html`.
3. Mengonfigurasi `/etc/nginx/sites-available/default`: `index.php`, aturan `rewrite ^/profil$ /profil.php last;`, dan `fastcgi_pass` ke socket PHP-FPM.
4. Restart `php8.4-fpm` dan `nginx`.
5. Menguji dari klien melalui hostname, termasuk `/profil`.
### 2. Command
 
**oblada dan molly**
```sh
apt-get update
apt-get install nginx php-fpm -y
rm -f /var/www/html/index.nginx-debian.html
ls /etc/php           # memastikan versi PHP (8.4)
```
 
`/var/www/html/index.php`
```php
<?php
echo "<h1>Selamat Datang di Beranda Core</h1>";
echo "<p>Ini adalah halaman utama di node " . gethostname() . ".</p>";
echo "<a href='profil'>Lihat Profil</a>";
?>
```
 
`/var/www/html/profil.php`
```php
<?php
echo "<h1>Halaman Profil</h1>";
echo "<p>Nama Node: " . gethostname() . "</p>";
echo "<p>Layanan web dinamis PHP-FPM berjalan sempurna (Clean URL aktif).</p>";
echo "<a href='/'>Kembali ke Beranda</a>";
?>
```
 
`/etc/nginx/sites-available/default`
```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.php index.html index.htm;
    server_name _;
 
    # Clean URL: /profil -> /profil.php
    rewrite ^/profil$ /profil.php last;
 
    location / {
        try_files $uri $uri/ =404;
    }
 
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
```
 
```sh
service php8.4-fpm restart
service nginx restart
```
 
> Catatan: percobaan awal dengan socket `php8.2`/`php8.3` menghasilkan `502 Bad Gateway`. Versi socket harus sama dengan versi hasil `ls /etc/php`.
 
**Verifikasi** (dari alpha)
```sh
curl oblada.k41.com
curl molly.k41.com
curl oblada.k41.com/profil
curl molly.k41.com/profil
curl core.k41.com             # round robin: ulangi beberapa kali
curl core.k41.com/profil
```
 
![Konfigurasi Nginx](assets/s10-nginx-conf.png)
 
> 📸 Isi `/etc/nginx/sites-available/default`, `index.php`, dan `profil.php` di salah satu node.
 
![curl beranda](assets/s10-curl-beranda.png)
 
> 📸 `curl oblada.k41.com` dan `curl molly.k41.com` (halaman beranda).
 
![curl profil](assets/s10-curl-profil.png)
 
> 📸 `curl oblada.k41.com/profil` dan `curl molly.k41.com/profil` (clean URL, tanpa `.php`).
 
![curl core](assets/s10-curl-core.png)
 
> 📸 `curl core.k41.com` dan `curl core.k41.com/profil` beberapa kali, terlihat bergantian oblada dan molly.

## Soal 11
Konfigurasikan Penny (menggunakan Apache) sebagai reverse proxy yang mengarah ke semua node di area vault (Obladi & Desmond).

Sementara itu, konfigurasikan Abbey (menggunakan Nginx) sebagai reverse proxy menuju area core (Oblada & Molly). Pastikan kedua gerbang ini meneruskan identitas asli pengunjung ke server backend dengan melakukan forwarding header Host dan X-Real-IP. Buktikan bahwa Penny dan Abbey berhasil mendistribusikan lalu lintas dengan tepat.

### Ringkasan
*Penny (Apache) menjadi reverse proxy sekaligus load balancer ke obladi dan desmond. Abbey (Nginx) menjadi reverse proxy sekaligus load balancer ke oblada dan molly. Keduanya meneruskan header `Host` dan `X-Real-IP`, lalu dibuktikan lewat log backend dan capture paket.*

### 1. Langkah Pengerjaan
1. Pada penny: mengaktifkan modul `proxy`, `proxy_http`, `proxy_balancer`, `lbmethod_byrequests`, `headers`, dan `rewrite`, lalu menonaktifkan site bawaan.
2. Pada penny: membuat VirtualHost `www.k41.com` di `010-penny-www.conf`. `ProxyPreserveHost On` meneruskan header `Host` asli, `RequestHeader set X-Real-IP` meneruskan IP pengunjung, dan blok `balancer://vault` berisi obladi serta desmond dengan metode `byrequests` (round robin).
3. Pada penny: potongan konfigurasi tambahan (`/admin` untuk Soal 12 dan `/eternal` untuk Soal 15) disimpan di `/etc/apache2/penny.d/` dan dimuat lewat `IncludeOptional` **sebelum** `ProxyPass "/"`, supaya path khusus tidak ikut diproxy ke vault.
4. Pada abbey: memasang `nginx`, menghapus site bawaan, lalu membuat `upstream core_backend` (oblada dan molly) dan server block `static.k41.com` yang meneruskan header `Host`, `X-Real-IP`, dan `X-Forwarded-For`. Potongan tambahan (`/orion` untuk Soal 15) dimuat dari `/etc/nginx/abbey.d/`.
5. Memvalidasi dengan `apachectl configtest` dan `nginx -t`, lalu restart masing-masing service.
6. Menguji dari klien: permintaan harus bergantian masuk ke dua backend. Header dibuktikan dengan `tcpdump` di backend.
   
### 2. Command
Pengaturan bersama (`/root/config.sh`, dipakai semua script) memuat `DOMAIN="k41.com"` beserta IP seluruh node.

**penny** — `soal11-penny.sh`
```sh
apt-get update
apt-get install -y apache2 apache2-utils
a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers rewrite
a2dissite 000-default.conf
mkdir -p /etc/apache2/penny.d
```

`/etc/apache2/sites-available/010-penny-www.conf`
```apache
<VirtualHost *:80>
    ServerName www.k41.com

    ProxyPreserveHost On
    RequestHeader set X-Real-IP "expr=%{REMOTE_ADDR}"

    IncludeOptional /etc/apache2/penny.d/*.conf

    <Proxy "balancer://vault">
        BalancerMember "http://10.84.1.4:80"
        BalancerMember "http://10.84.1.5:80"
        ProxySet lbmethod=byrequests
    </Proxy>
    ProxyPass        "/" "balancer://vault/"
    ProxyPassReverse "/" "balancer://vault/"

    ErrorLog  ${APACHE_LOG_DIR}/penny_error.log
    CustomLog ${APACHE_LOG_DIR}/penny_access.log combined
</VirtualHost>
```

```sh
a2ensite 010-penny-www.conf
apachectl configtest
service apache2 restart
```

**abbey** — `soal11-abbey.sh`
```sh
#!/bin/bash

[ -x /usr/sbin/nginx ] || {
  apt-get update -y
  apt-get install -y nginx
}

rm -f /etc/nginx/sites-enabled/default
mkdir -p /etc/nginx/abbey.d

cat > /etc/nginx/sites-available/abbey-static.conf <<'EOF'
upstream core_backend {
    server 10.84.1.6:80;   # oblada
    server 10.84.1.7:80;   # molly
}

server {
    listen 80;
    server_name static.k41.com;

    location / {
        proxy_pass http://core_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    include /etc/nginx/abbey.d/*.conf;
}
EOF

ln -sf /etc/nginx/sites-available/abbey-static.conf /etc/nginx/sites-enabled/abbey-static.conf
nginx -t && service nginx restart
```

`/etc/nginx/sites-available/abbey-static.conf`
```nginx
upstream core_backend {
    server 10.84.1.6:80;
    server 10.84.1.7:80;
}

server {
    listen 80;
    server_name static.k41.com;

    location / {
        proxy_pass http://core_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    include /etc/nginx/abbey.d/*.conf;
}
```

```sh
ln -sf /etc/nginx/sites-available/abbey-static.conf /etc/nginx/sites-enabled/abbey-static.conf
nginx -t
service nginx restart
```

**Verifikasi** (dari klien, node yang dipakai: beta atau alpha)
```sh
# distribusi ke vault (obladi/desmond) — /node.txt berisi nama node
for i in 1 2 3 4; do curl -s http://www.k41.com/node.txt; done

# distribusi ke core (oblada/molly) — beranda menampilkan nama node
for i in 1 2 3 4; do curl -s http://static.k41.com/; echo; done
```

Pada obladi dan desmond (serta oblada dan molly) dipantau bersamaan:
```sh
tail -f /var/log/apache2/access.log      # obladi, desmond
tail -f /var/log/nginx/access.log        # oblada, molly
```

Header `Host` dan `X-Real-IP` dibuktikan dengan capture paket pada backend:
```sh
apt-get install -y tcpdump
tcpdump -i any -A -s0 -l 'tcp dst port 80' 2>/dev/null | grep -iE '^(Host|X-Real-IP):'
```

Hasil yang diharapkan: nama node pada keluaran `curl` bergantian (obladi dan desmond, oblada dan molly); header yang tertangkap `Host: www.k41.com` (untuk vault) dan `Host: static.k41.com` (untuk core), dengan `X-Real-IP` berisi IP klien.

<img width="1920" height="1080" alt="Screenshot 2026-10-01 184703" src="https://github.com/user-attachments/assets/4d8eadde-a6bd-4a71-a54c-19b72d960650" />

## Soal 12
Terdapat ruang khusus di penny yang yang menyimpan dokumen rahasia sindikat, oleh karena itu terapkan perlindungan basic authentication untuk path /admin. Akses ke jalur tersebut harus menolak pengunjung tanpa kredensial, dan hanya mengizinkan masuk jika menggunakan credential berikut:
| username | password |
|---|---|
| prabs | `pakar_pinter_jadi_gob***` |

### Ringkasan
*Pasang basic authentication pada path `/admin` di penny. Pengunjung tanpa kredensial ditolak (401), dan hanya user `prabs` dengan password yang ditentukan yang boleh mas

### 1. Langkah Pengerjaan
1. Membuat folder `/var/www/admin` berisi halaman uji sebagai "dokumen rahasia".
2. Membuat berkas kredensial `/etc/apache2/.htpasswd` dengan `htpasswd` untuk user `prabs` (password diapit petik tunggal karena memuat tanda `*`).
3. Membuat potongan konfigurasi `penny.d/10-admin.conf`: `ProxyPass "/admin" "!"` agar `/admin` dilayani langsung oleh penny dan tidak diproxy ke vault, `Alias` ke folder admin, dan blok `<Directory>` dengan `AuthType Basic`.
4. Memvalidasi dengan `apachectl configtest`, lalu restart Apache.
5. Menguji tanpa kredensial, dengan kredensial salah, dan dengan kredensial benar.

### 2. Command
**penny** — `soal12-penny.sh`
```sh
#!/bin/bash
apt-get install -y apache2-utils

mkdir -p /etc/apache2/penny.d /var/www/admin

echo "Ruang Rahasia Sindikat - Area Admin" > /var/www/admin/index.html
htpasswd -bc /etc/apache2/.htpasswd prabs 'pakar_pinter_jadi_gob***'

cat > /etc/apache2/penny.d/10-admin.conf <<'EOF'
ProxyPass "/admin" "!"
Alias "/admin" "/var/www/admin"

<Directory /var/www/admin>
    AuthType Basic
    AuthName "Area Rahasia Sindikat"
    AuthUserFile /etc/apache2/.htpasswd
    Require valid-user
    Options FollowSymLinks
    AllowOverride None
</Directory>
EOF

apachectl configtest && service apache2 restart
```

`/etc/apache2/penny.d/10-admin.conf`
```apache
ProxyPass "/admin" "!"
Alias "/admin" "/var/www/admin"
<Directory "/var/www/admin">
    AuthType Basic
    AuthName "Area Admin"
    AuthUserFile /etc/apache2/.htpasswd
    Require valid-user
</Directory>
```

```sh
apachectl configtest
service apache2 restart
```

**Verifikasi** (dari klien)
```sh
curl -I http://www.k41.com/admin/
curl -I -u prabs:salah http://www.k41.com/admin/
curl -u 'prabs:pakar_pinter_jadi_gob***' http://www.k41.com/admin/
```

Hasil yang diharapkan: dua perintah pertama `401 Unauthorized` (header `WWW-Authenticate: Basic`), perintah ketiga menampilkan isi halaman admin.

<img width="1920" height="1080" alt="soal12_1" src="https://github.com/user-attachments/assets/38408341-192f-4778-aa46-c6c5bdab50ee" />

<img width="1920" height="1080" alt="soal12_2" src="https://github.com/user-attachments/assets/12d7716e-f02f-4b63-9e9a-f1a9037ce728" />

## Soal 13
Setiap entitas dari luar harus memanggil gerbang dengan nama kanoniknya. Jika ada yang mencoba mengakses IP penny dan domain penny.xxx.com, paksa sistem untuk melakukan redirect secara permanen (status code 301) menuju www.xxx.com. Sebaliknya, jika ada yang mengakses IP abbey dan domain abbey.xxx.com, lakukan redirect sementara (status code 302) menuju static.xxx.com.

### Ringkasan
*Akses ke IP penny atau `penny.k41.com` diarahkan permanen (301) ke `www.k41.com`. Akses ke IP abbey atau `abbey.k41.com` diarahkan sementara (302) ke `static.k41.com`.*

### 1. Langkah Pengerjaan
1. Pada penny: membuat VirtualHost `000-penny-redirect.conf`. Awalan `000` membuatnya dimuat pertama sehingga menjadi vhost default, yang menangkap akses lewat IP maupun nama lain. Isinya `Redirect permanent / http://www.k41.com/`.
2. Pada penny: menonaktifkan konfigurasi redirect lama bila ada, lalu restart Apache.
3. Pada abbey: membuat server block `000-abbey-redirect.conf` dengan `default_server` dan `server_name abbey.k41.com _`, berisi `return 302 http://static.k41.com$request_uri`. Server block `static.k41.com` (Soal 11) tetap dipilih berdasarkan nama, sehingga tidak ikut dialihkan.
4. Memvalidasi dengan `apachectl configtest` dan `nginx -t`, lalu restart.
5. Menguji dengan `curl -I` ke IP dan nama domain gerbang masing-masing.

### 2. Command
**penny** — `soal13-penny.sh`
```apache
# /etc/apache2/sites-available/000-penny-redirect.conf
<VirtualHost *:80>
    ServerName penny.k41.com
    Redirect permanent / http://www.k41.com/
</VirtualHost>
```
```sh
a2ensite 000-penny-redirect.conf
apachectl configtest
service apache2 restart
```

**abbey** — `soal13-abbey.sh`
```nginx
# /etc/nginx/sites-available/000-abbey-redirect.conf
server {
    listen 80 default_server;
    server_name abbey.k41.com _;
    return 302 http://static.k41.com$request_uri;
}
```
```sh
ln -sf /etc/nginx/sites-available/000-abbey-redirect.conf /etc/nginx/sites-enabled/
nginx -t
service nginx restart
```

**Verifikasi** (dari klien)
```sh
curl -I http://10.84.5.2          # IP penny      -> 301, Location: http://www.k41.com/
curl -I http://penny.k41.com      # nama penny    -> 301, Location: http://www.k41.com/
curl -I http://10.84.4.2          # IP abbey      -> 302, Location: http://static.k41.com/
curl -I http://abbey.k41.com      # nama abbey    -> 302, Location: http://static.k41.com/
curl -I http://www.k41.com/       # kanonik penny -> 200 (tidak dialihkan)
curl -I http://static.k41.com/    # kanonik abbey -> 200 (tidak dialihkan)
```

> Catatan: konfigurasi redirect abbey tidak boleh menjadi satu-satunya server block di Nginx. Bila `static.k41.com` tidak punya server block sendiri (Soal 11), permintaan ke `static.k41.com` jatuh ke server block redirect dan menghasilkan redirect berulang ke dirinya sendiri.

<img width="1920" height="1080" alt="soal13" src="https://github.com/user-attachments/assets/624be256-8efe-4414-b378-9379b17a65fe" />

## Soal 14
Di dalam The Mesh, rekam jejak tidak boleh dipalsukan oleh sistem. Pastikan access log pada setiap server web di area vault maupun area core mencatat alamat IP asli milik client (pengunjung) yang diteruskan oleh gerbang, dan bukan mencatat IP dari Penny ataupun Abbey.

### Ringkasan
*Access log di obladi, desmond (Apache) dan oblada, molly (Nginx) harus mencatat IP asli klien. Header `X-Real-IP` dari gerbang dipercaya hanya jika berasal dari penny (untuk vault) atau abbey (untuk core).*

### 1. Langkah Pengerjaan
1. Pada obladi dan desmond: mengaktifkan modul `remoteip` dan menulis `RemoteIPHeader X-Real-IP` serta `RemoteIPInternalProxy 10.84.5.2` (penny).
2. Pada oblada dan molly: menulis `set_real_ip_from 10.84.4.2` (abbey) dan `real_ip_header X-Real-IP` pada `conf.d/realip.conf`, sehingga variabel `$remote_addr` berisi IP klien asli.
3. Membersihkan percobaan lama (format log `X-Forwarded-For` yang tidak terpakai) agar tidak bertabrakan.
4. Memvalidasi konfigurasi, lalu restart service.
5. Mengirim permintaan dari klien lewat gerbang dan membaca access log backend.

### 2. Command
**obladi dan desmond** — `soal14-vault.sh`
```sh
#!/bin/bash

a2disconf custom-log 2>/dev/null
a2disconf remoteip-penny 2>/dev/null
rm -f /etc/apache2/conf-available/custom-log.conf /etc/apache2/conf-available/remoteip-penny.conf

a2enmod remoteip
cat > /etc/apache2/conf-available/realip.conf <<'EOF'
RemoteIPHeader X-Real-IP
RemoteIPInternalProxy 10.84.5.2
EOF
a2enconf realip

apachectl configtest && service apache2 restart
```

**oblada dan molly** — `soal14-core.sh`
```sh
#!/bin/bash

grep -rl proxy_ip /etc/nginx 2>/dev/null | xargs -r sed -i '/log_format proxy_ip/d; s| proxy_ip;|;|'

cat > /etc/nginx/conf.d/realip.conf <<'EOF'
set_real_ip_from 10.84.4.2;
real_ip_header X-Real-IP;
EOF

nginx -t && service nginx restart
```

> Catatan: `RemoteIPInternalProxy` dipilih, bukan `RemoteIPTrustedProxy`. Pada pengujian, `RemoteIPTrustedProxy` tidak menggantikan alamat klien yang berada di rentang IP privat (10.84.x.x), sehingga log tetap mencatat IP penny.

**Verifikasi**
```sh
# klien (mis. alpha, 10.84.6.2)
ip -br a show eth0
curl -s http://www.k41.com/info.txt
curl -s http://static.k41.com/ > /dev/null

# obladi / desmond
tail -n 3 /var/log/apache2/access.log
# oblada / molly
tail -n 3 /var/log/nginx/access.log
```

Hasil yang diharapkan: kolom alamat pada baris log terakhir berisi IP klien (`10.84.6.2` bila dari alpha), bukan `10.84.5.2` (penny) atau `10.84.4.2` (abbey).

<img width="1920" height="1080" alt="soal14_1" src="https://github.com/user-attachments/assets/fb944d36-0423-49ad-bde4-a55d7f4a27d2" />

<img width="1920" height="1080" alt="soal14_2" src="https://github.com/user-attachments/assets/8c226657-732c-4d7e-989b-75914d1b2869" />

<img width="1920" height="1080" alt="soal14_3" src="https://github.com/user-attachments/assets/1db0dd5e-65d6-4057-88f3-0dd50c555c8a" />

## Soal 15
Rootkit menginstruksikan pembuatan jalur proxy khusus yang berdiri sendiri. Pada penny buat reverse proxy untuk path /eternal yang menyajikan directory /var/www/eternal, dan pastikan path ini dapat mengeksekusi (rendering) file php. Pada abbey, buat jalur /orion yang menyajikan directory /var/www/orion, secara murni statis tanpa perlu rendering php.

### Ringkasan
*Pada penny, path `/eternal` diproxy ke backend lokal yang menyajikan `/var/www/eternal` dan mengeksekusi PHP. Pada abbey, path `/orion` menyajikan `/var/www/orion` sebagai berkas statis murni tanpa PHP.*

### 1. Langkah Pengerjaan
1. Pada penny: memasang `libapache2-mod-php`, lalu membuat `/var/www/eternal/index.php`.
2. Pada penny: membuat backend yang berdiri sendiri, yaitu VirtualHost `127.0.0.1:8081` dengan `DocumentRoot /var/www/eternal` (`Listen 127.0.0.1:8081` pada `ports.conf`). Port ini hanya dapat diakses dari penny sendiri.
3. Pada penny: menambahkan `penny.d/20-eternal.conf` berisi `ProxyPass "/eternal" "http://127.0.0.1:8081"` sehingga `/eternal` diproxy ke backend lokal tersebut.
4. Pada abbey: membuat `/var/www/orion/index.html` dan berkas `tes.php` (untuk membuktikan PHP tidak dieksekusi).
5. Pada abbey: menambahkan `abbey.d/20-orion.conf` yang dimuat ke dalam server block `static.k41.com`. Blok `location ^~ /orion/` memakai `root /var/www` dan tidak memuat `fastcgi_pass`.
6. Memvalidasi konfigurasi, restart service, lalu menguji dari klien.
   
### 2. Command
**penny** — `soal15-penny.sh`
```sh
#!/bin/bash
apt-get install -y php-fpm
a2enmod proxy_fcgi

for s in /etc/init.d/php*-fpm; do $s start; done
SOCK=$(ls /run/php/php*-fpm.sock | head -1)

mkdir -p /etc/apache2/penny.d /var/www/eternal

cat > /var/www/eternal/index.php <<'EOF'
<?php
echo "Eternal PHP Rendered Successfully di Penny";
echo "<br>Hostname: " . gethostname();
?>
EOF

cat > /etc/apache2/penny.d/20-eternal.conf <<EOF
ProxyPass "/eternal" "!"
Alias "/eternal" "/var/www/eternal"

<Directory /var/www/eternal>
    Options FollowSymLinks
    DirectoryIndex index.php
    Require all granted
    <FilesMatch "\.php\$">
        SetHandler "proxy:unix:${SOCK}|fcgi://localhost"
    </FilesMatch>
</Directory>
EOF

apachectl configtest && service apache2 restart
```

`/var/www/eternal/index.php`
```php
<?php
echo "<h1>Eternal - penny</h1>";
echo "<p>PHP dieksekusi. Versi: " . phpversion() . "</p>";
echo "<p>Waktu: " . date('Y-m-d H:i:s') . "</p>";
```

`/etc/apache2/sites-available/020-penny-eternal.conf`
```apache
<VirtualHost 127.0.0.1:8081>
    DocumentRoot /var/www/eternal
    <Directory /var/www/eternal>
        Require all granted
        DirectoryIndex index.php index.html
    </Directory>
    ErrorLog  ${APACHE_LOG_DIR}/eternal_error.log
    CustomLog ${APACHE_LOG_DIR}/eternal_access.log combined
</VirtualHost>
```

`/etc/apache2/penny.d/20-eternal.conf`
```apache
ProxyPass        "/eternal" "http://127.0.0.1:8081"
ProxyPassReverse "/eternal" "http://127.0.0.1:8081"
```

```sh
echo 'Listen 127.0.0.1:8081' >> /etc/apache2/ports.conf
a2ensite 020-penny-eternal.conf
apachectl configtest
service apache2 restart
```

**abbey** — `soal15-abbey.sh`
```sh
#!/bin/bash
mkdir -p /var/www/orion /etc/nginx/abbey.d

cat > /var/www/orion/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head><title>Orion</title></head>
<body><h1>Orion Static Page di Abbey</h1></body>
</html>
EOF

cat > /var/www/orion/tes.php <<'EOF'
<?php echo "Kalau ini terbaca sebagai kode, PHP tidak dirender"; ?>
EOF

cat > /etc/nginx/abbey.d/orion.conf <<'EOF'
location = /orion {
    return 301 /orion/;
}

location /orion/ {
    alias /var/www/orion/;
    index index.html;
}
EOF

# bersihkan sisa percobaan lama di server block redirect
sed -i '/snippets\/orion.conf/d' /etc/nginx/sites-available/redirect-abbey 2>/dev/null
rm -f /etc/nginx/snippets/orion.conf

nginx -t && service nginx restart
```

`/etc/nginx/abbey.d/20-orion.conf`
```nginx
location = /orion { return 301 /orion/; }
location ^~ /orion/ {
    root /var/www;
    index index.html;
}
```

```sh
nginx -t
service nginx restart
```

**Verifikasi** (dari klien)
```sh
curl http://www.k41.com/eternal/            # PHP dirender menjadi HTML
curl http://static.k41.com/orion/           # halaman statis
curl http://static.k41.com/orion/tes.php    # kode PHP tampil mentah, tidak dieksekusi
curl -I http://static.k41.com/orion         # 301 ke /orion/
```

> Catatan: pada percobaan awal, `/orion` menghasilkan `302 Found` karena potongan konfigurasi ditempatkan pada server block redirect (Soal 13), bukan pada server block `static.k41.com`. Percobaan awal `/eternal` menghasilkan `404` karena permintaan ikut diproxy ke vault. Kunci perbaikannya: potongan khusus dimuat sebelum `ProxyPass "/"` di penny, dan include `/orion` diletakkan di dalam server block `static.k41.com` di abbey.


<img width="1920" height="1080" alt="soal15_1" src="https://github.com/user-attachments/assets/3cf3bdf4-fceb-455d-9699-21cca851d629" />

<img width="1920" height="1080" alt="soal15_2" src="https://github.com/user-attachments/assets/499b3b6d-d02f-4e50-9d65-e0ab231d586d" />

## Soal 16
Ketahanan gerbang The Mesh harus diuji untuk menghadapi bombardir permintaan. Salah satu Klien (misal: Alpha) bertugas melakukan stress test benchmark menggunakan ApacheBench. Lakukan 250 requests dengan tingkat konkurensi (concurrencies) 10 untuk masing - masing titik akhir: www.xxx.com dan static.xxx.com. Tampilkan rangkuman hasilnya.

### Ringkasan
*Dari alpha, jalankan ApacheBench dengan 250 request dan konkurensi 10 ke `www.k41.com` dan `static.k41.com`, lalu tampilkan rangkuman hasilnya.*

### 1. Langkah Pengerjaan
1. Memasang `apache2-utils` pada alpha (menyediakan perintah `ab`).
2. Menjalankan `ab -n 250 -c 10` ke `http://www.k41.com/` dan `http://static.k41.com/` (garis miring di akhir wajib ada).
3. Menyimpan keluaran lengkap ke berkas dan menampilkan rangkuman metrik utama.
   
### 2. Command
**alpha** — `soal16-alpha.sh`
```sh
apt-get update
apt-get install -y apache2-utils

ab -n 250 -c 10 http://www.k41.com/    | tee /root/ab-www.txt
ab -n 250 -c 10 http://static.k41.com/ | tee /root/ab-static.txt

grep -E 'Concurrency Level|Time taken|Complete requests|Failed requests|Non-2xx|Requests per second|Time per request' /root/ab-www.txt /root/ab-static.txt
```

**Rangkuman hasil**

| Metrik | www.k41.com (penny → vault) | static.k41.com (abbey → core) |
|---|---|---|
| Complete requests | 250 | 250 |
| Concurrency level | 10 | 10 |
| Failed requests | 0 | 0 |
| Non-2xx responses | tidak ada | tidak ada *(setelah Soal 11 dan 13 benar)* |
| Requests per second | 511,48 #/sec | *(isi dari hasil `ab` terbaru)* |
| Time per request (mean) | 19,551 ms | *(isi dari hasil `ab` terbaru)* |
| Time per request (across all concurrent) | 1,955 ms | *(isi dari hasil `ab` terbaru)* |

> Catatan: pada percobaan awal, `ab` ke `static.k41.com` melaporkan `Non-2xx responses: 250` karena abbey masih membalas dengan redirect 302 (server block `static.k41.com` belum ada). Setelah Soal 11 dan 13 diperbaiki, seluruh respons bernilai 2xx.


<img width="1920" height="1080" alt="soal16_1" src="https://github.com/user-attachments/assets/d1fe78ad-4c95-47de-8dc9-c70f127d31ca" />

<img width="1920" height="1080" alt="soal16_2" src="https://github.com/user-attachments/assets/00493b40-43e3-439b-a457-1603f6038746" />

## Soal 17
Tambahkan TXT record pada DNS untuk semua klien sayap kiri dan sayap kanan (Alpha, Beta, Gamma, Delta, Epsilon). Jika DNS di-query TXT terhadap nama domain mereka (contoh: alpha.<xxxx>.com), sistem harus mengembalikan teks berupa nama hostname mereka masing-masing (contoh: "alpha").

### Ringkasan
*Tambahkan TXT record untuk alpha, beta, gamma, delta, dan epsilon pada zona `k41.com` di prab. Query TXT ke `alpha.k41.com` harus mengembalikan `"alpha"`, dan seterusnya.*

### 1. Langkah Pengerjaan
1. Menambahkan lima TXT record pada `/etc/bind/jarkom/k41.com` di prab (nama domain sama dengan A record klien, nilai berupa hostname).
2. Menaikkan serial SOA agar tedd menarik zona terbaru.
3. Memvalidasi dengan `named-checkzone`, lalu `service named restart` di prab, kemudian tedd.
4. Menguji `dig TXT` ke prab dan tedd.
   
### 2. Command
*prab** — tambahan di `/etc/bind/jarkom/k41.com` (`soal17-prab.sh`)
```
alpha    IN  TXT  "alpha"
beta     IN  TXT  "beta"
gamma    IN  TXT  "gamma"
delta    IN  TXT  "delta"
epsilon  IN  TXT  "epsilon"
```

```sh
named-checkzone k41.com /etc/bind/jarkom/k41.com
service named restart        # prab, lalu tedd
```

**Verifikasi**
```sh
dig TXT alpha.k41.com @10.84.1.2
dig TXT alpha.k41.com @10.84.1.3
for h in alpha beta gamma delta epsilon; do dig +short TXT $h.k41.com; done
```

Hasil yang diharapkan: jawaban `"alpha"`, `"beta"`, `"gamma"`, `"delta"`, `"epsilon"` dengan flag `aa`, dan serial SOA prab sama dengan tedd.


<img width="1920" height="1080" alt="soal17_1" src="https://github.com/user-attachments/assets/1efe4e4e-147e-49b0-971d-0cc20f3c762c" />

<img width="1920" height="1080" alt="soal17_2" src="https://github.com/user-attachments/assets/8642c60e-6e0a-4171-8340-8b5fb7c5543f" />

## Soal 18
Ubah A record DNS milik abbey.xxx.com ke alamat IP yang fiktif (ubah secara random namun pastikan format IP valid). Naikkan nilai serial SOA di prab dan pastikan tedd ikut tersinkron. Tetapkan TTL sebesar 15 detik pada record yang relevan tersebut. Verifikasi momen yang terjadi pada tiga fase pencarian: sebelum perubahan terjadi (mengembalikan IP lama), saat perubahan baru saja terjadi dalam jeda 15 detik (masih IP lama karena cache), dan setelah batas waktu TTL habis (berubah ke IP fiktif yang baru).

### Ringkasan
*Ubah A record `abbey.k41.com` ke IP fiktif dengan TTL 15 detik, naikkan serial SOA, pastikan tedd sinkron, lalu verifikasi tiga fase: sebelum perubahan, saat 15 detik pertama (cache), dan setelah TTL habis.*

### 1. Langkah Pengerjaan
1. Menetapkan TTL 15 detik **pada record abbey saja** (`abbey 15 IN A ...`), bukan pada seluruh zona.
2. Memasang resolver cache kecil (`dnsmasq`, port 5353) pada prab yang meneruskan ke BIND prab. Server otoritatif tidak menyimpan cache untuk zonanya sendiri, sehingga tanpa resolver cache fase "masih IP lama karena cache" tidak dapat diamati. Resolver ini berperan sebagai resolver klien.
3. **Fase 1** — mencatat jawaban sebelum perubahan (IP lama `10.84.4.2`).
4. Mengubah A record abbey ke IP fiktif `192.0.2.99`, menaikkan serial SOA, reload BIND.
5. **Fase 2** — langsung `dig` kembali (kurang dari 15 detik): jawaban masih IP lama dari cache dan TTL menurun.
6. Menunggu 16 detik. **Fase 3** — `dig` kembali: jawaban berubah ke IP fiktif.
7. Memverifikasi serial SOA di prab dan tedd sama, dan abbey di tedd sudah mengembalikan IP fiktif.

### 2. Command
**prab** — `soal18-prab.sh`
```sh
apt-get install -y dnsmasq-base dnsutils
dnsmasq -C /dev/null --port=5353 --listen-address=127.0.0.1 --bind-interfaces \
        --no-resolv --no-hosts --server=10.84.1.2#53 --cache-size=150 --pid-file=/run/dnsmasq-test.pid
```

Baris abbey di `/etc/bind/jarkom/k41.com` diubah dengan `sed`; contoh hasil akhir:
```
abbey   15  IN  A   192.0.2.99
```

Alur fase pada skrip:
```sh
# persiapan: IP asli dengan TTL 15 detik (serial dinaikkan, BIND di-reload)
dig @127.0.0.1 -p 5353 abbey.k41.com A +noall +answer     # FASE 1: 10.84.4.2

# ubah ke IP fiktif, naikkan serial, reload BIND
dig @127.0.0.1 -p 5353 abbey.k41.com A +noall +answer     # FASE 2: masih 10.84.4.2 (cache)

sleep 16
dig @127.0.0.1 -p 5353 abbey.k41.com A +noall +answer     # FASE 3: 192.0.2.99
```

**Verifikasi sinkron tedd**
```sh
dig +short SOA k41.com @10.84.1.2
dig +short SOA k41.com @10.84.1.3
dig +short abbey.k41.com @10.84.1.3
```

<img width="1920" height="1080" alt="soal18_1" src="https://github.com/user-attachments/assets/c83f801b-b433-4390-a534-f69ea94b87e6" />

<img width="1920" height="1080" alt="soal18_2" src="https://github.com/user-attachments/assets/79033972-c733-408c-be6c-6aad7d3522f2" />

<img width="1920" height="1080" alt="soal18_3" src="https://github.com/user-attachments/assets/f669cfa2-be2d-4cd2-8bb8-550c69943919" />

<img width="1920" height="1080" alt="soal18_4" src="https://github.com/user-attachments/assets/bbb81d0c-e555-4d86-8829-cbf9b968c4ec" />

## Soal 19
Last? But not least? Buat CNAME record yang melakukan binding dari domain internal outbound.xxx.com menuju domain eksternal http.badssl.com, Lakukan perintah curl ke http://outbound.xxx.com dan pastikan output yang dihasilkan sesuai dengan isi konten di halaman http.badssl.com.

### Ringkasan
*Buat CNAME `outbound.k41.com` menuju `http.badssl.com`, lalu `curl http://outbound.k41.com` harus menghasilkan konten yang sama dengan `http.badssl.com`.*

### 1. Langkah Pengerjaan
1. Menambahkan CNAME `outbound` pada zona `k41.com` di prab. Titik di akhir `http.badssl.com.` wajib ada agar dibaca sebagai FQDN dan tidak ditambahi `k41.com`.
2. Menaikkan serial SOA, memvalidasi, lalu restart `named` di prab dan tedd.
3. Memastikan prab dapat merekursi ke luar lewat forwarder `192.168.122.1` (agar CNAME ke domain eksternal dapat ter-resolve).
4. Menjalankan `dig` dan `curl` dari klien, lalu membandingkan keluarannya dengan `curl http://http.badssl.com`.
   
### 2. Command
**prab** — tambahan di `/etc/bind/jarkom/k41.com` (`soal19-prab.sh`)
```
outbound  IN  CNAME  http.badssl.com.
```

```sh
named-checkzone k41.com /etc/bind/jarkom/k41.com
service named restart        # prab, lalu tedd
```

**Verifikasi** (dari klien)
```sh
dig outbound.k41.com
curl http://outbound.k41.com
curl http://http.badssl.com
diff <(curl -s http://outbound.k41.com) <(curl -s http://http.badssl.com) && echo SAMA
```

<img width="1920" height="1080" alt="soal19_1" src="https://github.com/user-attachments/assets/87317660-b360-4fdd-bfaa-6b1b86bdfbd0" />
<img width="1920" height="1080" alt="soal19_2" src="https://github.com/user-attachments/assets/9927d6f1-1b55-40d8-bfd1-5d083a3eaba5" />

## Soal 20
Setelah semua penyelesaian selesai, pastikan semua service dan konfigurasi yang telah dikerjakan dari awal tetap berjalan normal dan berstatus autostart saat node di-restart (khusus untuk kasus ini, abaikan konfigurasi nomor 18 dan biarkan koordinat kembali normal).

### Ringkasan
*Pastikan semua service dan konfigurasi tetap berjalan dan otomatis hidup setelah node di-restart. Konfigurasi Soal 18 dikembalikan ke normal.*

### 1. Langkah Pengerjaan
1. Mengembalikan A record abbey ke `10.84.4.2` (TTL kembali ke default zona), menaikkan serial SOA, reload BIND, lalu mematikan resolver cache uji Soal 18 (`soal18-revert.sh`).
2. Node GNS3 berbasis container tanpa systemd, sehingga service dinyalakan melalui blok autostart pada `/root/.bashrc` yang dijalankan saat console dibuka. Blok ini menulis ulang `/etc/resolv.conf` (prab → tedd → 192.168.122.1) dan menyalakan service bila belum berjalan.
3. Memasang blok autostart sesuai peran node: `apache2` (penny, obladi, desmond), `nginx` (abbey), `nginx` dan `php-fpm` (oblada, molly), `named` (prab, tedd).
4. Mematikan lalu menyalakan kembali node di GNS3, membuka console, dan memeriksa resolver serta status service.
5. Menguji ulang alur utama (`www`, `static`, `/admin`, DNS) dari klien.
   
### 2. Command
**prab** — `soal18-revert.sh`
```sh
sed -i -E 's/^abbey[[:space:]].*/abbey IN A 10.84.4.2/' /etc/bind/jarkom/k41.com
# serial dinaikkan, lalu:
service named restart
dig +short abbey.k41.com @10.84.1.2        # 10.84.4.2
```

**Setiap node (kecuali rootkit)** — `soal20-autostart.sh <service>`
```sh
bash /root/soal20-autostart.sh apache2        # penny, obladi, desmond
bash /root/soal20-autostart.sh nginx          # abbey
bash /root/soal20-autostart.sh nginx php      # oblada, molly
bash /root/soal20-autostart.sh named          # prab, tedd
bash /root/soal20-autostart.sh                # klien (hanya resolver)
```

Blok yang ditambahkan pada `/root/.bashrc` (contoh node nginx + php):
```sh
# >>> mesh-autostart >>>
printf 'nameserver 10.84.1.2\nnameserver 10.84.1.3\nnameserver 192.168.122.1\n' > /etc/resolv.conf
service nginx status >/dev/null 2>&1 || service nginx start >/dev/null 2>&1
for f in /etc/init.d/php*-fpm; do ... ; done
# <<< mesh-autostart <<<
```

**Verifikasi** (setelah node di-stop lalu di-start dari GNS3)
```sh
cat /etc/resolv.conf
service apache2 status      # penny, obladi, desmond
service nginx status        # abbey, oblada, molly
service named status        # prab, tedd

# dari klien
curl -I http://www.k41.com/
curl -I http://static.k41.com/
curl -I http://www.k41.com/admin/
dig +short abbey.k41.com
```

> Catatan: paket dan konfigurasi dapat hilang bila node di-reset penuh. Karena itu seluruh langkah disimpan sebagai script di `/root` dan di folder `script/`. `jalankan-semua.sh` membangun ulang seluruh konfigurasi satu node secara berurutan.

<img width="1920" height="1080" alt="soal20" src="https://github.com/user-attachments/assets/0bff5ef5-fe90-4f22-80d6-6a5616aba7ca" />
