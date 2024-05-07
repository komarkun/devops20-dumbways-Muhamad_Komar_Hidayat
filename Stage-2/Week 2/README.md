# Tugas devops Dumbways Week 2 Stage 2

Repository :
[Dumbflix Backend](https://github.com/dumbwaysdev/dumbflix-backend)

Tasks :

- Deploy database mysql
  - Setup secure_installation
  - Add password for `root` user
  - Create new user for mysql
  - Create new database
  - Create privileges for new users so they can access the database you created
  - Dont forget to change the mysql bind address on `/etc/mysql/mysql.conf.d/mysqld.cnf`
  - Try to remote your database from your local computer or gateway server
- Deploy aplikasi Wayshub-Backend
  - Clone wayshub backend application
  - Use Node Version 14
  - Dont forget to change configuration on `wayshub-backend/config/config.json` and then adjust it to your database.
  - Install sequelize-cli
  - Running migration
  - Deploy apllication on Top PM2

# Jawaban Tugas

## Deploy database mysql

### Setup secure_installation

Untuk menggunakan database mysql kita perlu install database mysql nya dulu di terminal linux nya dengan perintah:

```bash
# update repository apt supaya security nya terbaru
sudo apt-get update

# upgrade repository apt yg tersedia (jika ada)
sudo apt-get -y upgrade

# install mysql-server untuk menggunakan databases
sudo apt-get install -y mysql-server

# cek instalation mysql
sudo mysql --version
```

![Alt text](./images/database-img/mysql-installation1.png "img")

Untuk secure installation bisa menggunakan perintah:

```bash
sudo mysql_secure_installation
```

![Alt text](./images/database-img/mysql-installation2.png "img")

### Add password for `root` user

untuk mengubah password root yang default nya adalah kosong atau tampa password bisa menggunakan perintah di terminal mysql :

```mysql
# command to set password root
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('mypass');

# command to reload mysql
FLUSH PRIVILEGES;
```

setelah password di setup kita bisa login di terminal bash linux dengan password baru :

```bash
sudo mysql -u root -p
```

### Create new user for mysql

untuk membuat user baru kita masuk ke terminal mysql dan wajib login pakai root lalu masukan perintah:

```
# untuk buat user dengan ip localhost saja
CREATE USER 'komar'@'localhost'IDENTIFIED BY 'password';

# untuk buat user dengan allow semua ip
CREATE USER 'komar'@'%'IDENTIFIED BY 'password';
```

![Alt text](./images/database-img/mysql-createuser.png "img")

setelah kita buat user kita juga perlu tambahkan privileges supaya si user baru bisa menjalankan perintah sesuai harapan yang di inginkan seperti membuat table, database, dll dengan perintah:

```
# mengizinkan user menggunakan database dan table
GRANT PRIVILEGE ON database.table TO 'username'@'host';

# mengizinkan user menggunakan beberapa privileges
GRANT CREATE, ALTER, DROP, INSERT, UPDATE, DELETE, SELECT, REFERENCES, RELOAD on *.* TO 'komar'@'localhost' WITH GRANT OPTION;

# mengizinkan semua privileges ke user
GRANT ALL PRIVILEGES ON *.* TO 'komar'@'localhost' WITH GRANT OPTION;
```

setelah privileges di setup kita bisa login dengan user tersebut ke mysql nya. dan untuk login bisa dengan method biasa atau kita juga bisa menggunakan aplikasi lain seperti DB-eaver CE untuk login ke database dan menjalankan mysql secara GUI

login seperti biasa

```bash
sudo mysql -u komar -p
```

![Alt text](./images/database-img/mysql-login-with-new-user.png "img")

login menggunakan DB-eaver CE
![Alt text](./images/database-img/mysql-login-with-new-user-dbeaver.png "img")

### Create new database

untuk membuat database baru di terminal mysql bisa menggunakan perintah:

```
CREATE DATABASE db_dumbflix;
```

### Create privileges for new users so they can access the database you created

karena user saya (komar) sudah di GRANT all privileges jadi user juga sudah bisa membuat database langsung

```
# mengizinkan user menggunakan database dan table
GRANT PRIVILEGE ON database.table TO 'username'@'host';

# mengizinkan user menggunakan beberapa privileges
GRANT CREATE, ALTER, DROP, INSERT, UPDATE, DELETE, SELECT, REFERENCES, RELOAD on *.* TO 'komar'@'localhost' WITH GRANT OPTION;

# mengizinkan semua privileges ke user
GRANT ALL PRIVILEGES ON *.* TO 'komar'@'localhost' WITH GRANT OPTION;
```

### change the mysql bind address on `/etc/mysql/mysql.conf.d/mysqld.cnf`

Agar database kita bisa di akses oleh aplikasi yang berjalan di luar server kita misalnya, kita harus mengubah beberapa konfigurasi yang berada di file /etc/mysql/mysql.conf.d/mysqld.cnf

![Alt text](./images/database-img/mysql-vim-to-mysql.conf.png "img")

![Alt text](./images/database-img/mysql-vim-inside-mysql.conf.png "img")

Konfigurasi yang di ubah:

```
bind-address = 0.0.0.0
mysql-bind-address = 0.0.0.0
```

ini supaya kita bisa login dimanapun dengan ip yang lain atau di vm machine yang lain ip nya, dan ip 0.0.0.0 ini supaya kita bisa allow from anywhere ini mirip seperti yang ada di mongodb atlas.

### Try to remote your database from your local computer or gateway server

untuk remote ke database kita karena kita sudah atur konfigurasi dari mysql nya kita bisa login atau remote ke database tersebut dari mana saja. disini saya mencontohkan login memakai aplikasi DB-eaver CE agar kita bisa mengtur database secara Graphical User Interface.

![Alt text](./images/database-img/mysql-login-with-new-user-dbeaver.png "img")

tinggal masukan saja server host, username, password, port dan nama database nya
![Alt text](./images/database-img/mysql-dbaver-success-login.png "img")

## Deploy aplikasi Dumbflix-Backend

Untuk Mendeploy aplikasi Dumbflix-backend di VM yang ke 2 saya menggunakan docker container karena saya pengen mengimplementasikan NGINX PROXY MANAGER juga buar routing reserve proxy serta SSL sertificate juga agar koneksi aplikasi bisa jadi HTTPS dan lebih secure serta sangat enak karena menggunakan GUI.

script installation Docker & docker compose "docker-install.sh".

```sh
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

jalan kan di terminal script tersubut agar bisa menggunakan docker dan docker-compose

```bash
# command run script as sudo
sudo sh docker-install.sh

# check docker version
sudo docker --version

# check docker-compose version
sudo docker-compose --version
```

### Set up NGINX PROXY MANAGER

configurasi container NGINX PROXY MANAGER, pakai docker-compose.yaml

```yaml
version: "3.8"
services:
  app:
    image: "docker.io/jc21/nginx-proxy-manager:latest"
    restart: unless-stopped
    ports:
      - "80:80"
      - "81:81"
      - "443:443"
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
```

Jalankan container nya:

```bash
sudo docker-compose up -d
```

Periksa aplikasi nginx proxy managernya dan buat ssl sertificate serta buat proxy host

![Alt text](./images/backend-img/nginx-proxy-manager-ssl.png "img")

![Alt text](./images/backend-img/nginx-proxy-manager-hosts.png "img")

Setelah container ngixn proxy manager di setup, kita tinggal setup container untuk aplikasi dumbflix backend nya

### Clone wayshub backend application

kita cllone dulu aplikasi dumbflix backend nya.
![Alt text](./images/backend-img/clone-dumbflix-backend.png "img")

change configuration on `wayshub-backend/config/   config.json` and then adjust it to your database.

![Alt text](./images/backend-img/edit-configurasi-.envnya.png "img")

setelah itu kita buat Dockerfile langsung buat setup container aplikasi backendnya. isi dari docker file nya adalah :

```
FROM node:14

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

RUN npm i sequelize-cli

COPY . .

RUN npx sequelize db:migrate

EXPOSE 5000

CMD [ "node", "server.js" ]
```

setelah itu kita bisa mengeksekusi docker file nya dan membuat images dengan perintah:

```bash
sudo docker build -t docker.io/komarkun/dumbflix_backend .
```

jalankan container nya dengan images yang sudah di buat dengan perintah:

```bash
sudo docker run -d -p 5000:5000 --name dumbflix-backend docker.io/komarkun/dumbflix_backend
```

cek container berjalan :

```bash
sudo docker ps
```

![Alt text](./images/backend-img/docker-build&run-dumbflix-backend.png "img")

setelah kontainer berjalan buat proxy hosts nya supaya aplikasi backend kita berjalan di https pakai nginx proxy manager dan adjust si ssl nya.
![Alt text](./images/backend-img/nginx-proxy-manager-hosts.png "img")

di VM 1 tempat dumbflix frontend di setup Change url for dumbflix-backend in src/config/api.js supaya di pointing ke dns backend nya. case saya api.komar.studentdumbways.my.id

jalankan aplikasi dumbfilx front end nya, karena sudah terhubung ke backned dan database kita bisa register, kalo berhasil artinya bagus successssss
![Alt text](./images/backend-img/register-di-frontend.png "img")

kalau success kita bisa cek di database datanya tersimpan atau tidak
![Alt text](./images/backend-img/cek-register-dbeaver.png "img")

![Alt text](./images/backend-img/1.png "img")
![Alt text](./images/backend-img/2.png "img")
![Alt text](./images/backend-img/3.png "img")
![Alt text](./images/backend-img/4.png "img")
