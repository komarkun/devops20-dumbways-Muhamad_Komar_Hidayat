# Tugas devops Dumbways Mandiri Project Week 2 Stage 2

## DAY 1

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
