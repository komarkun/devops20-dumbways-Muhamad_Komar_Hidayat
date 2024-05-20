# Tugas devops Dumbways Project Week 3 Stage 2 (Cara 1)

## DAY 1 Docker & Docker Compose

Tasks :
[ Docker ]

- Jelasakan langkah-langkah melakukan rebuild server BiznetGio, dan ubah menggunakan os ubuntu 22
- Setelah server sudah selesai ter rebuild, buatlah suatu user baru dengan nama **team kalian** .
- Buatlah bash script se freestyle mungkin untuk melakukan installasi docker.
- Deploy aplikasi Web Server, Frontend, Backend, serta Database on top `docker compose`
  - Buat suatu docker compose yang berisi beberapa service kalian
    - Web Server
    - Frontend
    - Backend
    - Database
  - Di dalam docker-compose file buat suatu custom network dengan nama **team kalian**, lalu pasang ke setiap service yang kalian miliki.
  - Deploy database terlebih dahulu menggunakan mysql dan jangan lupa untuk pasang volume di bagian database.
  - Untuk building image frontend dan backend sebisa mungkin buat dockerized dengan image sekecil mungkin. dan jangan lupa untuk sesuaikan configuration dari backend ke database maupun frontend ke backend sebelum di build menjadi docker images.
  - Untuk Web Server buatlah configurasi reverse-proxy menggunakan nginx on top docker.
    - **SSL CLOUDFLARE OFF!!!**
    - Gunakan docker volume untuk membuat reverse proxy
    - SSL sebisa mungkin gunakan wildcard
    - Untuk DNS bisa sesuaikan seperti contoh di bawah ini
      - Frontend team1.studentdumbways.my.id
      - Backend api.team1.studentdumbways.my.id
  - Push image ke docker registry kalian masing".
- Aplikasi dapat berjalan dengan sesuai seperti melakukan login/register.

## JAWABAN

### Rebuild server BiznetGio

1. login ke biznet gio

![Alt text](./images/Login-ke-biznet-gio.png "img")

2. Pergi ke dashboard lalu klik ke vm yg mau di Rebuild

![Alt text](./images/1.%20Pergi%20ke%20dashboard.png "img")

3. Stop VM lalu klik tombol rebuild dan pilih server ubuntu 22 dan setup ssh keys nya

![Alt text](./images/2.%20Stop%20VM%20lalu%20rebuilds.png "img")

4. Periksa Kembali status server (running atau tidak)

![Alt text](./images/3.%20Periksa%20server%20running.png "img")

5. Periksa login kembali di host machine dan remove know_host sebelumnya

![Alt text](./images/4.%20Periksa%20login%20dengan%20ssh%20dan%20remove%20known_host%20sebelumnya%20karena%20sudah%20di%20rebuild.png "img")

6. Jika berhasil Login proses rebuild selesai, YEAY

![Alt text](./images/5.%20Login%20kembali%20setelah%20rebuild%20berhasil.png "img")

### buatlah suatu user baru dengan nama **team2**

untuk membuat user baru di terminal linux kita bisa masukan perintah sebagai berikut :

![Alt text](./images/6.%20Buat%20User%20baru%20dengan%20sudo%20add%20user.png "img")

```bash
# Menambahkan user
sudo adduser team2

# Menambahkan user baru agar punya sudo (super user do)
sudo usermod -aG sudo team2
```

Periksa kembali installasi user baru dengan pidah ke user tersebut di terminal dengan perintah :

![Alt text](./images/7.%20Pindah%20user%20dengan%20perintah%20su%20-%20team2.png "img")

```bash
# pindah user
su - team2

# masukan password nya
password:
```

### Installasi Docker menggunakan bashscript atau (.sh) file

untuk melakukan installasi docker kita harus menuju ke repository original docker untuk menginstall docker engine di linux server kita, isi dari bashscript nya adalah:

![Alt text](./images/8.%20Vim%20Instalasi%20docker%20script%20file.png "img")

docker-install.sh

atau gunakan chmod +x docker-install.sh supaya jadi executable

```bash
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

# Install all docker tools
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

```

untuk menjalankan installasi script bisa menggunakan perinatah:

![Alt text](./images/9.%20Jalankan%20script%20install%20docker.png "img")

```bash
# run script
sudo sh docker-install.sh

# atau
sudo ./docker-install.sh
```

kita juga bisa menambahkan permission supaya kita bisa menjalankan docker tampa sudo (super user do)

![Alt text](./images/10.%20Tambahkan%20Permission%20team2%20for%20docker.png "img")

setelah semua dijalankan periksa apakah docker sudah terinstall atau belum

![Alt text](./images/11%20Periksa%20installasi%20docker.png "img")

### Deploy aplikasi Web Server, Frontend, Backend, serta Database on top `docker compose` Nama aplikasi = wayshub

Sebelum menjalankan aplikasi kita wajib Pull terlebih dahulu source code nya dari git hub dengan perintah:

![Alt text](./images/13.%20clone%20semua%20repository%20code%20yang%20di%20butuhkan.png "img")

```bash
# Pull Frontend App
git clone https://github.com/dumbwaysdev/wayshub-frontend.git

# Pull Backend App
git clone https://github.com/dumbwaysdev/wayshub-backend.git
```

### Setup VM

#### VM1 (gateway) untuk setup Frontend dan Nginx secara container

```yaml
services:
  frontend:
    image: wayshub-frontend-prod
    container_name: wayshub-frontend
    ports:
      - "3000:80"
    restart: always
    stdin_open: true
    networks:
      - team2

  webserver:
    image: nginx:latest
    container_name: webserver
    depends_on:
      - frontend
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "./nginx:/etc/nginx/conf.d"
      - "./nginx/certs:/etc/nginx/certs"
    networks:
      - team2
networks:
  team2:
```

#### VM2 (appserver) untuk setup Backend & database & Nginx secara container

```yaml
services:
  database:
    image: mysql:5.7
    container_name: database
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: komarganteng
      MYSQL_DATABASE: wayshub
      MYSQL_USER: komar
      MYSQL_PASSWORD: komarganteng
    ports:
      - "3306:3306"
    volumes:
      - ./mysql/data:/var/lib/mysql
    networks:
      - team2
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 30s
      timeout: 10s
      retries: 5
  backend:
    image: wayshub-backend
    container_name: wayshub-backend
    restart: always
    stdin_open: true
    ports:
      - "5000:5000"
    depends_on:
      database:
        condition: service_healthy
    networks:
      - team2
  webserver:
    image: nginx:latest
    container_name: webserver
    depends_on:
      - frontend
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "./nginx:/etc/nginx/conf.d"
      - "./nginx/certs:/etc/nginx/certs"
    networks:
      - team2
```

kita juga bisa membuat satu docker compose yang berisi semua configuration file di dalam satu project. tapi di projek ini nanti akan dipisah ke 2 vm karena jika di gabung semua akan berat dan leg juga, berikut ini adalah contoh semua aplikasi di deploy di satu vm:

![Alt text](./images/12.%20Buat%20file%20docker-compose%20file.png "img")

```yaml
services:
  database:
    image: mysql:5.7
    container_name: database
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: komarganteng
      MYSQL_DATABASE: wayshub
      MYSQL_USER: komar
      MYSQL_PASSWORD: komarganteng
    ports:
      - "3306:3306"
    volumes:
      - ./mysql/data:/var/lib/mysql
    networks:
      - team2
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 30s
      timeout: 10s
      retries: 5

  webserver:
    image: nginx:latest
    container_name: webserver
    depends_on:
      - frontend
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "./nginx:/etc/nginx/conf.d"
      - "./nginx/certs:/etc/nginx/certs"
    networks:
      - team2

  frontend:
    image: wayshub-frontend
    container_name: wayshub-frontend
    ports:
      - "3000:3000"
    restart: always
    depends_on:
      - backend
    stdin_open: true
    volumes:
      - ./wayshub-frontend/container-data:/app
    networks:
      - team2

  backend:
    image: wayshub-backend
    container_name: wayshub-backend
    restart: always
    stdin_open: true
    ports:
      - "5000:5000"
    depends_on:
      database:
        condition: service_healthy
    networks:
      - team2

networks:
  team2:
```

setelah ada configuration file kita pis jalankan "docker compose pull"

![Alt text](./images/14.%20docker%20compose%20pull%20images%20di%20terminal.png "img")

### Custom network Docker & Docker compose

untuk membuat custom network di docker bisa menggunakan perintah:

```bash
# Create Network
docker network create team2

# Periksa Network
docker network ls || docker network ps
```

Untuk membuat custom network di docker compose sebenernya jika kita tidak mendefine network nya maka otomatis akan dibuatkan oleh docker compose, tapi jika ingin membuat manual bisa saja tinggal di taruh di docker-compose.yaml nya saja contoh:

```yaml
services:
  backend:
    image: wayshub-backend
    container_name: wayshub-backend
    restart: always
    stdin_open: true
    ports:
      - "5000:5000"
    depends_on:
      database:
        condition: service_healthy
    networks:
      - team2

networks:
  team2:
```

### Deploy database mysql dan Setup Backend di vm2

agar kita bisa mensetup backend aplikasi untuk wayshub backend kita perlu setup database terlebih dahulu lalu setelahnya kita bisa build images untuk aplikasi backend nya. disini saya menggunakan docker compose untuk menjalankan database dan saya pointing juga dengan docker volume supaya data nya tidak hilang.

docker-compose-mysql.yaml

```yaml
services:
  database:
    image: mysql:5.7
    container_name: database
    environment:
      MYSQL_ROOT_PASSWORD: komarganteng
      MYSQL_DATABASE: wayshub
      MYSQL_USER: komar
      MYSQL_PASSWORD: komarganteng
    ports:
      - "3306:3306"
    volumes:
      - ./mysql/data:/var/lib/mysql
    networks:
      - team2
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 30s
      timeout: 10s
      retries: 5
networks:
  team2:
```

Set up volume di docker compose nya supaya databse tidak hilang dan jalankan perintah berikut:

```bash
docker compose -f docker-compose-mysql.yaml up -d
```

setelah database di setup terlebih dahulu baru kita bisa build images untuk backend aplikasi kita, kita setup terlebih dahulu semua configurasi di kode backend agar bisa terhubung ke database, setelah itu build image backend nya.

Dockerfile

```Dockerfile
FROM node:14

WORKDIR /app

COPY package*.json ./

RUN npm install

RUN npm i sequelize-cli

COPY . .

RUN npx sequelize db:migrate

EXPOSE 5000

CMD [ "npm", "start" ]
```

jalankan docker build di terminal dengan perintah:

```bash
docker build -t wayshub-backend .
```

![Alt text](./images/15.%20docker%20build%20backend.png "img")

setelah images backend selesai dibuat kita bisa jalankan aplikasi backend dan database, serta nginx untuk reserve proxy menggunakan docker compose langsung, yang configurasinya adalah sebagai berikut:

```yaml
services:
  database:
    image: mysql:5.7
    container_name: database
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: komarganteng
      MYSQL_DATABASE: wayshub
      MYSQL_USER: komar
      MYSQL_PASSWORD: komarganteng
    ports:
      - "3306:3306"
    volumes:
      - ./mysql/data:/var/lib/mysql
    networks:
      - team2
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 30s
      timeout: 10s
      retries: 5
  backend:
    image: wayshub-backend
    container_name: wayshub-backend
    restart: always
    stdin_open: true
    ports:
      - "5000:5000"
    depends_on:
      database:
        condition: service_healthy
    networks:
      - team2
  webserver:
    image: nginx:latest
    container_name: webserver
    depends_on:
      - frontend
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "./nginx:/etc/nginx/conf.d"
      - "./nginx/certs:/etc/nginx/certs"
    networks:
      - team2
```

![Alt text](./images/16.%20docker%20run%20backend.png "img")

```bash
docker compose up -d
```

### Deploy Frontend aplication di vm 1

setelah database dan backend kita berjalan kita bisa langsung setup frontend nya, terlebih dahulu kita ubah beberapa configurasi di dalam kode agar aplikasi bisa terhubung dengan backend dengan megganti url nya ke https://be.api.komar.studentdumbways.my.id/ setelah selesai semuanya kita bisa build image juga untuk frontend.

berikut adalah configurasi Dockerfile untuk membuild images frontend:

Dockerfile

```Dockerfile
FROM node:14

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

CMD ["npm","start"]
```

build Dockerfile diatas dengan perintah:

```bash
docker build -t wayshub-frontend .
```

![Alt text](./images/17.%20docker%20build%20frontend.png "img")

setelah images selesai kita build kita juga bisa membuat docker compose file nya, configurasi nya adalah sebagai berikut:

docker-compose.yaml

```yaml
services:
  frontend:
    image: wayshub-frontend-prod
    container_name: wayshub-frontend
    ports:
      - "3000:80"
    restart: always
    stdin_open: true
    networks:
      - team2

  webserver:
    image: nginx:latest
    container_name: webserver
    depends_on:
      - frontend
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "./nginx:/etc/nginx/conf.d"
      - "./nginx/certs:/etc/nginx/certs"
    networks:
      - team2
networks:
  team2:
```

untuk menjalankan dengan docker compose perintahnya:

```bash
docker compose up -d
```

setelah itu cek apakah aplikasinya berjalan atau tidak di browser:

link app: https://komar.studentdumbways.my.id

![Alt text](./images/18.%20wayshub%20signup.png "img")

![Alt text](./images/19.%20wayshub%20signin.png "img")

![Alt text](./images/20.%20wayshub%20add%20video.png "img")

![Alt text](./images/21.%20wayshub%20subscription.png "img")

![Alt text](./images/22.%20wayshub%20home.png "img")

### Resize docker images sekecil dan seefisien mungkin

Supaya Docker images kita ukurannya bisa kecil dan efisien cara yang paling mudah adalah mengatur configurasi saat membuild nya, Misalnya:

#### Untuk Frontend

Dockerfile-Normal

Ukuran Images = 1.1GB

```Dockerfile
FROM node:14

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

CMD ["npm","start"]
```

Konfigurasi Dockerfile diatas adalah konfigurasi normal untuk menjalankan Dockerfile, tetapi images yang dihasilkan masih sangat besar karena biasanya base image oleh node JS yang di gunakan di file tersebut menggunakan base ubuntu yang sangat besar dan memakan banyak resource.

Ukuran Images = 307MB

Dockerfile-alpine

```Dockerfile
FROM node:14-alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

CMD ["npm","start"]
```

Konfigurasi di atas diganti menggunakan node JS dengan base images linux apine, linux alpine ini sangat lah kecil dan tidak memakan resource yang banyak seperti saat kita menggunakan node JS dengan base images ubuntu yg sangat berat.

Multistage build images

Docker-multistage-build

Ukuran Images = 50MB

```Dockerfile
FROM node:14-alpine as build

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80 for the Nginx server
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

Cara yang paling efektif untuk mengecilkan images dan dapat digunakan untuk production build adalah dengan menggunakan multiple build stage, jadi ada 2 kali build di sana untuk aplikasi khususnya frontend, kita bisa build dahulu di layer dockerfile nya agar aplikasi frontend menjadi kecil setelah melakukan build lalu layer berikutnya atau proses build ke 2 adalah dengan menjalankan aplikasi static file yang telah di build tersebut dengan menggunakan nginx web server untuk images nya, dan hasil yang akan di dapatkan nantinya adalah aplikasi kita akan punya images yang sangat kecil dan dapat di gunakan dengan lebih maksimal lagi.

![Alt text](./images/23.%20docker%20images%20resize%20to%20max%20production.png "img")

#### Untuk Backend

khusus untuk backend agar images yg di buat bisa jadi kecil saya hanya menggunakan base images node JS nya menggunakan alpine saja. karena jika di build aplikasi backend node js output nya beda seperti aplikasi frontend yg bisa berupa static file tapi backend node js masih tetap butuh runtime dari node js langsung nya agar tetap berjalan.

![Alt text](./images/24.%20backend%20images%20resize.png "img")

![Alt text](./images/25.%20backend%20resize%20Dockerfile.png "img")

### Webserver (NGINX) & Wild Card SSL Certificate & Cloudflare on Container

kita buat terlebih dahulu DNS Record agar IP address dari VM kita yg ada di Frontend dan Backend dapat di pointing ke masing2 IP VM di biznet gio menggunakan Cloudflare DNS Record.

![Alt text](./images/26.%20cloudflare%20DNS%20Record.png "img")

Frontend: komar.studentdumbways.my.id

Backend: api.komar.studentdumbways.my.id

Untuk SSL certificate Wildcard saya menggunakan Certbot untuk generate satu kali SSL sertificate yang nantinya bisa di gunakan untuk semua SSL.

Docs Installation Certbot WildCard :
https://certbot.eff.org/instructions?ws=nginx&os=ubuntufocal&tab=wildcard

```bash
sudo snap install --classic certbot

sudo ln -s /snap/bin/certbot /usr/bin/certbot

sudo snap set certbot trust-plugin-with-root=ok

sudo snap install certbot-dns-cloudflare
```

Setup Credential cloudflare terlebih dahulu dan simpan ke dalam file cloudflare.ini di lokasi /root/.secret/cloudflare.ini

```ini
dns_cloudflare_email = "emailname@gmail.com"
dns_cloudflare_api_key = "Token isi Here"
```

setelah di setup jalankan perintah berikut untuk genereate SSL sertificate wildcard dari cloudflare dan lestencritp via certbot

```bash
certbot certonly --dns-cloudflare --dns-cloudflare-credentials /root/.secrets/cloudflare.ini -d komar.studentdumbways.my.id,*.komar.studentdumbways.my.id --preferred-challenges dns-01
```

buat configurasi default.conf untuk nginx reserve_proxy

```conf
server {
	listen 80;
 	listen 443 ssl;
 	server_name komar.studentdumbways.my.id;

 	ssl_certificate /etc/nginx/certs/fullchain.pem;
 	ssl_certificate_key /etc/nginx/certs/privkey.pem;

	location / {
  	proxy_pass http://frontend:80;
  	proxy_set_header Host $host;
  	proxy_set_header X-Real-IP $remote_addr;
	}
}

server {
	if ($host = komar.studentdumbways.my.id) {
	return 301 https://$host$request_uri;
	}

	listen 80;
	server_name komar.studentdumbways.my.id;
	return 404;
}
```

Taruh configurasi tersebut di folder nginx karena folder tersebut sudah di konfigurasi di container di docker compose nya. dan jangan lupa jalankan terlebih dahulu docker-compose.yaml nya untuk menjalankan service nginx.

![Alt text](./images/27.%20Service%20Nginx%20running.png "img")

Jangan lupa copy juga File SSL Certificate wildcard nya juga ke dalam folder nginx/cert, Berikut adalah gambaran file nya

![Alt text](./images/28.%20isi%20ssl%20nginxconf.png "img")

```yaml
services:
  frontend:
    image: wayshub-frontend-prod
    container_name: wayshub-frontend
    ports:
      - "3000:80"
    restart: always
    stdin_open: true
    networks:
      - team2

  webserver:
    image: nginx:latest
    container_name: webserver
    depends_on:
      - frontend
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "./nginx:/etc/nginx/conf.d"
      - "./nginx/certs:/etc/nginx/certs"
    networks:
      - team2
networks:
  team2:
```

running kembali docker compose nya

```bash
docker compose down

docker compose up -d
```

Periksa kembali aplikasinya nanti dia bisa running Secara HTTPS, dan SSL Sertificate akan menyala.
link app: https://komar.studentdumbways.my.id

![Alt text](./images/18.%20wayshub%20signup.png "img")

![Alt text](./images/19.%20wayshub%20signin.png "img")

![Alt text](./images/20.%20wayshub%20add%20video.png "img")

![Alt text](./images/21.%20wayshub%20subscription.png "img")

![Alt text](./images/22.%20wayshub%20home.png "img")

### Push Images Ke Docker Registry

agar kita bisa push ke registry kita wajib login dahulu menggunakan docker login, lalu image kita beri tagname sesuai dengan username/namaimages agar kita bisa push ke registry kita.

![Alt text](./images/29.%20docker%20push%20ke%20registry.png "img")

![Alt text](./images/30.%20check%20pushed%20registry.png "img")
