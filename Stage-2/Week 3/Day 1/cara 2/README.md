# Tugas devops Dumbways Mandiri Project Week 3 Stage 2 (Cara 2)

## DAY 1 Docker & Docker Compose

Tasks :
[ Docker ]

- Deploy aplikasi Web Server, Frontend, Backend, serta Database on top `docker compose` SEMUANYA DOCKER COMPOSE
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
      - Frontend komar.studentdumbways.my.id
      - Backend api.komar.studentdumbways.my.id
  - Push image ke docker registry kalian masing".
- Aplikasi dapat berjalan dengan sesuai seperti melakukan login/register.

## JAWABAN CARA 2 (SEMUA DOCKER COMPOSE)

Untuk Mendeploy aplikasi baik frontend maupun backend menggunakan docker compose, terlebih dahulu kita harus punya source codenya bisa dari github, gitlab ataupun scm manapun, lalu kita wajib menginstall docker engine di server maupun di local machine kita sesuai kebutuhan. dan kita juga harus sudah menyiapkan server yang akan kita gunakan.

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242104654251425963/image.png?ex=664c9f9a&is=664b4e1a&hm=18f02fb724728ff5f605778c614dc72d18b68f2562ed522f5dd08152308282da&)

Ex wayshub-backend:

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242101231862677614/image.png?ex=664c9c6a&is=664b4aea&hm=871822e0c0e0c7be7c91b243f8c42f168120fd9268c43798ccfa85a0c2abc673&)

Ex wayshhub-fronend:

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242101739902074930/image.png?ex=664c9ce3&is=664b4b63&hm=bebc9405ae6fd502980eca1e67570bbaf095b981799e976792036f039be63587&)

Setelah punya source code dari aplikasi kita buat dulu Dockerfile biasa supaya kita bisa membuat image yang nantinya bisa kita pakai untuk me running aplikasi di dalam kontainer. Dockerfile merupakan blueprint atau serangkaian perintah untuk menjalankan aplikasi kita yang nantinya akan berjalan di kontainer docker tentunya.

Ex Dockerfile Frontend:

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242103019970105414/image.png?ex=664c9e15&is=664b4c95&hm=c77e45b5e0acf2bca29c9206024ec78653bc0e0c099b6c0918247bc7eb3c1db1&)

Ex Dockerfile Backend:

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242103430730748085/image.png?ex=664c9e77&is=664b4cf7&hm=278a01d667d6dda0ef2ca2f2199cbca08801ffc63e6c73da9ae7892930007b17&)

setelah Dockerfilenya ada kita bisa buat images dulu dengan perintah:

```bash
# di frontend directory
docker build -t komarkun/wayshub-frontend:latest .

# di backend directory
docker build -t komarkun/wayshub-backend:latest .
```

setelah image dan semua bahannya ada kita bisa langsung buat docker compose nya di masing2 server sesuai kebutuhan.

docker-compose.yaml

```
Server1 = (nginx & certbot)

Server2 = (wayshub-frontend)

Server3 = (wayshub-backend)
```

docker-compose.yaml di server1

```yaml
services:
  webserver:
    container_name: nginx
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    restart: always
    volumes:
      - ./nginx/conf:/etc/nginx/conf.d
      - ./certbot/www/:/var/www/certbot
      - ./certbot/conf/:/etc/letsencrypt
    depends_on:
      - certbot
    networks:
      - team2

  certbot:
    container_name: certbot
    image: certbot/dns-cloudflare:latest
    volumes:
      - ./certbot/certbot.ini:/etc/letsencrypt/renewal/renewal.conf:ro
      - ./certbot/www/:/var/www/certbot
      - ./certbot/conf/:/etc/letsencrypt
    command:
      [
        "certonly",
        "--non-interactive",
        "--dns-cloudflare",
        "--dns-cloudflare-credentials",
        "/etc/letsencrypt/renewal/renewal.conf",
        "--email",
        "komarhidayat0@gmail.com.com",
        "--agree-tos",
        "--no-eff-email",
        "--server",
        "https://acme-v02.api.letsencrypt.org/directory",
        "--domain",
        "*.komar.studentdumbways.my.id",
        "--domain",
        "komar.studentdumbways.my.id",
      ]
    networks:
      - team2
networks:
  team2:
```

docker-compose.yaml di server2

```yaml
services:
  frontend:
    container_name: wayshub-frontend-prod
    image: komarkun/wayshub-frontend-prod:latest
    stdin_open: true
    ports:
      - "3000:80"
    networks:
      - team2

networks:
  team2:
```

docker-compose.yaml di server3

```yaml
services:
  database:
    image: mysql:latest
    container_name: database
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: komarganteng
      MYSQL_DATABASE: wayshub
      MYSQL_USER: komarganteng
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
    image: komarkun/wayshub-backend-prod
    container_name: wayshub-backend-prod
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

setelah docker-compose.yaml siap di semua server langkah selanjutnya adalah kita tiggal jalan kan konfigurasi tersebut di masing masing server untuk menjalankan aplikasi tersebut:

```bash
docker compose up -d
```

lalu tinggal cek saja di browser
![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242107451650609295/image.png?ex=664ca235&is=664b50b5&hm=69e7f633b62809880d4d8a96b6d011bc5f66ebafac04a7e4e751856d6bed07c2&)

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242107916790792303/image.png?ex=664ca2a4&is=664b5124&hm=7afaebb7d898881da9fd2a77720c3e74a5661961b933971dbd3c2e995dc2b56f&)

Untuk building image frontend dan backend sebisa mungkin buat dockerized dengan image sekecil mungkin. dan jangan lupa untuk sesuaikan configuration dari backend ke database maupun frontend ke backend sebelum di build menjadi docker images.

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242109962113515560/image.png?ex=664ca48c&is=664b530c&hm=bfe5c51f6a055b2795fe4000a1bf08d4eb37e0bdec93149a6a281c4127cf606b&)

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242109962491134003/image.png?ex=664ca48c&is=664b530c&hm=ef62e5bb71908d69ba04f971f5b3c174c604ab022f41b9068d71b9df8c4043c1&)

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242109962872684648/image.png?ex=664ca48c&is=664b530c&hm=73643ebd7433b8df192e8b2cdedd6490741275a1a0297513ea564ed26b3acd3d&)

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242109963241914478/image.png?ex=664ca48c&is=664b530c&hm=b6401f90c6c4ff1072641646e3a1140141df6c2327e48df87b866d222104b7ae&)

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242109963577589854/image.png?ex=664ca48c&is=664b530c&hm=85a86a0ca9dbb949849d5b6a0f741c398acb5d8a82ee24ba66a1f6c0324387b2&)

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242109963979980871/image.png?ex=664ca48c&is=664b530c&hm=d1735afd4e7bf4986620ed2865ba48cf84091a830902f8c9d2f79badaa0e950a&)

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242109964336758814/image.png?ex=664ca48c&is=664b530c&hm=870d04bf31390ba6b3daafd548cf1f95afde834a979517a3400648ed5884e2fb&)

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242109964655263896/image.png?ex=664ca48c&is=664b530c&hm=6da8a610cdc39d90b423221ae20d679becc6e7646fe8f7c58ccdd348bfb67bf7&)

Untuk menconfigurasi reserve proxy dan wild card SSL sertificate kita wajib buat terlebih dahulu cloudflare DNS Record nya
![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242111450156371988/42.png?ex=664ca5ef&is=664b546f&hm=5ed00d0ad4e7854d800b88e3aec28ba2a942097c91879c882e00ce3d3177c2c7&)

setelah itu kita buat file reserve proxy nya dan token api keys nya juga dari cloudflare

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242111450625998979/43.png?ex=664ca5ef&is=664b546f&hm=5f059e00d20ad02eb6fcb19a476f0cef59f16b8d95f11a5b232f9298e7586896&)

Setelah itu ita jalankan service yang ada di docker compose nya di vm yang sudah di pointing ip adddress nya di cloudflare

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242111451586363493/45.png?ex=664ca5ef&is=664b546f&hm=592122b5201d031d220a5b677a3267587abf78107abb0da51ecb4a12a5439d12&)

jika sudah selesai kita bisa memnjalankan aplikasi kita tapi bedanya sekarang adalah sudah https dan juga wildcard ssl sertificate nya juga pasti berjalan juga

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242111452027031592/46.png?ex=664ca5ef&is=664b546f&hm=fec74b1d4f4709e710470fbcd76b090457b02274d086aab20e3806a25e35cc2d&)

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242111452374892656/47.png?ex=664ca5ef&is=664b546f&hm=5dca1809ef4d034259ec3cd4465e1c9c9cc022072e987cc874ac6a888a74bbab&)

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242111495790395452/52.png?ex=664ca5f9&is=664b5479&hm=628c6e6b8d29b7c827c98e150a3e2d1561fd95b812762f54475e79445588a26d&)

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242111496373407754/53.png?ex=664ca5fa&is=664b547a&hm=b206df169c131d09006f63db69f8bff42abf2aaee5439dc56d51e97f89839ebb&)

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242111497006481549/54.png?ex=664ca5fa&is=664b547a&hm=1f2a7ef82fa2389ee3f7de6e8e7316d7d3ad4dc5c1ff64a2da06ddc5d841b29b&)

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242111497476247632/55.png?ex=664ca5fa&is=664b547a&hm=af63e39c1438f15f8f3848a81ada20a2617fff96faa2dfdc9aeccf1db6c69678&)

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242111498189541386/56.png?ex=664ca5fa&is=664b547a&hm=936e44c62848633d91a1b8a1da14852278c0ffc02cdec4819538d332e1e84380&)

![Alt text](https://cdn.discordapp.com/attachments/1242100371355340831/1242111498734669885/57.png?ex=664ca5fa&is=664b547a&hm=d1d7dcc347aaeafab396285001c1e3f4e2ee16ede95d563834bfa43a82d3c79e&)
