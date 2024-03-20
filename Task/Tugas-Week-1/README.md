# Tugas devops Dumbways Week 1

## Task :

1. Perbedaan antara IP Private & Public, serta IP Dynamic & Static!
2. Buat penjelasan singkat tentang Virtualization!
3. Buat rancangan sebuah jaringan dengan spesifikasi sebagai berikut! - CIDR Block : 192.168.1.xxx/24 - Subnet : 255.255.255.0 - Gateway : 192.168.1.1
   (Gunakan app.diagrams.net untuk membuat diagramnya, Referensi gambar sudah disertakan)
4. Buat step-by-step untuk menginstall Virutal Machine via VMware, Virtualbox atau VM pilihan kalian!

## Jawaban :

1. Penjelasan IP

### perbedaan IP Privat & Public

- IP Privat biasanya digunakan untuk Router dan Semua Device yang berada di dalam area jangkauannya. atau bisa juga diartikan jaringan privat ini penggunaannya hanya untuk pribadi dan khususuntuk di local saja. karena tidak semua orang dari luar jaringan bisa mengakses ke dalam IP kita, hanya orang dengan IP yang terhubung ke jaringan privat saja (jaringan yg sama) saja yg bisa terhubung satu sama lain di jaringan tersebut.

Spesifikasi IP Privat:

- Menggunakan Class type C / default subnet mask (255.255.255.0) artinya hanya angka 0 saja atau blok ke 4 yg bisa di isi oleh angka ip sesuai keinginan kita dari range 0 - 254 keknya, sisanya yg angka 255 dari blok 1 sampai 3 angkanya sudah ditentukan, bisa oleh router atau provider ISP nya.

```html
Spesifikasi IP Privat: 1. Class Type C / Default subnet mask (255.255.255.0)
artinya hanya angka 0 saja atau blok ke 4 yg bisa di isi oleh angka ip sesuai
keinginan kita 2.Maksimal Host per network 254 jumlah total host yg bisa di
gunakan terbatas cuma 254 3. slash Notation /24 Contoh: Defauld Route :
192.168.0.1 (class type C (255.255.255.0)) IPv4 Address : 192.168.0.200 (angka
200 bisa di ganti apapun asal dalam range 0 - 254) ![alt
text](https://drive.google.com/file/d/1Zsb-MYm_S8aGsa1lpPBO0zFmd07xySqv/view)
```
