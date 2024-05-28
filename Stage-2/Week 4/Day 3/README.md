# Tugas Devops dumbways Week 4 day 3 Ansible & Ansible playbook

[Local]
Buat konfigurasi Ansible & sebisa mungkin maksimalkan penggunaan ansbile untuk melakukan semua setup dan se freestyle kalian

[ansible]
Buatlah ansible untuk :

- Membuat user baru beserta generate ssh-key nya, lalu test masuk ke user tersebut.
- Instalasi Docker
- Deploy application frontend yang sudah kalian gunakan sebelumnya menggunakan ansible.
- Instalasi Monitoring Server (node exporter, prometheus, grafana)
- Setup reverse-proxy
- Generated SSL certificate
- dan yang paling penting make your own kind ansible script dengan rapi dan jelas. dan sebisa mungkin jangan **MENCONTEK** milik teman lain karena script akan terlihat sekali perbedaan nya di materi ansible ini.
- agar script terlihat rapi, implementasikan penggunaan variable di script kalian.
- simpan script kalian ke dalam github dengan format tree sebagai berikut:

```sh
  Automation
  |
  | Terraform
  └─|  └── main.tf
    Ansible
    ├── ansible.cfg
    ├── lolrandom1.yaml
    ├── group_vars
    │ └── all
    ├── Inventory
    ├── lolrandom2.yaml
    └── lolrandom3.yaml
```

# JAWABAN

Untuk menggunakan Ansible dan ansible playbook, kita perlu menginstall aplikasinya dulu bisa di local komputer kita atau pun diserver manapun. disini saya untuk penginstallan sendiri menggunakan homebrew.

![alt text](./images/1.%20installasi%20ansible.png)

setelah ansibel sudah di siapkan aplikasinya, kita langusng siapkan saja directory nya. structur dirctory yg saya buat disini adalah sebagai berikut.

![alt text](./images/2.%20ansible%20tree%20local.png)i
Membuat user baru beserta generate ssh-key nya, lalu test masuk ke user tersebut.

Instalasi Docker

![alt text](./images/3.%20installasi%20docker.png)

![alt text](./images/4.1%20docker%20success.png)

Deploy application frontend yang sudah kalian gunakan sebelumnya menggunakan ansible.
![alt text](./images/4.%20deploy%20aplikasi%20frontend.png)

![alt text](./images/4.0%20frontend%20success.png)

Instalasi Monitoring Server (node exporter, prometheus, grafana)

![alt text](./images/5.%20installasi%20monitoring.png)

![alt text](./images/5.1%20grafana%20success.png)

contoh running the ansible books
![alt text](./images/6.%20run%20ansible.png)
![alt text](./images/6.1.png)
![alt text](./images/6.2.png)
![alt text](./images/6.3.png)
![alt text](./images/6.4.png)
![alt text](./images/7.%20gambar%20tree%20directory.png)

# Untuk Semua Script lihat saja di folder Automation yang ada di week 4
