# Challenge

## 1. Rubah nama hostname menjadi "dumbways"

Step BY step

- Gunakan perintah cd /etc untuk pergi ke directory etc lalu ketik ls buat menampilkan
  ![Alt text](./img/ss-cln1-a.png "step")
- Gunakan perintah sudo vim hostname untuk mengedit hostname
  ![Alt text](./img/ss-cln1-b.png "step")
- Ganti nama hosname yg tadinya ganteng jadi dumways
  ![Alt text](./img/ss-cln1-c.png "step")
- masukan perintah reboot di terminal agar perubahan jalan
  ![Alt text](./img/ss-cln1-d.png "step")
- Login kembali dan disini hostname sudah berubah
  ![Alt text](./img/ss-cln1-e.png "step")
- Selesay maybeee
  ![Alt text](./img/ss-cln1-f.png "step")

## 2. Buat network adapter baru dengan nama ens20 dan gunakan IP yang sama

Step BY step

- gunakan perintah cd /etc/netplan lalu ls
  ![Alt text](./img/ss-cln2-a.png "step")
- gunakan perintah cp untuk mengcoppy file lama atau bisa dengan membuat file baru dengan perintah touch
  ![Alt text](./img/ss-cln2-b.png "step")
- edit configurasi .yaml menggunakan perintah sudo vim / nano dll
  ![Alt text](./img/ss-cln2-c.png "step")
- ganti aja enp02s ke ens20 biar garibet lah atau buat file baru aja
  ![Alt text](./img/ss-cln2-d.png "step")
- apply dengan perintah sudo netplan apply dan reboot
