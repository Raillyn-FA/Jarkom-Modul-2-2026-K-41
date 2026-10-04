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
