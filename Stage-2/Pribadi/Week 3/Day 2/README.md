# Tugas devops Dumbways Mandiri Project Week 3 Stage 2

## DAY 2 CI/CD with Jenkins

Tasks :
[ Jenkins ]

- Installasi Jenkins on top Docker or native
- Setup SSH-KEY di local server jenkins kalian, agar dapat login ke dalam server menggunakan SSH-KEY
- Reverse Proxy Jenkins
  - gunakan domain ex. pipeline-team1.studentdumbways.my.id
  - reverse proxy sesuaikan dengan ketentuan yang ada di dalam Jenkins documentation
- Buatlah beberapa Job untuk aplikasi kalian
  - Job Backend
  - Untuk script CICD atur flow pengupdate an aplikasi se freestyle kalian dan harus mencangkup
    - Pull dari repository
    - Dockerize/Build aplikasi kita
    - Push ke Docker Hub
    - Test application
    - Deploy aplikasi on top Docker
- Auto trigger setiap ada perubahan di SCM
- Buat job notification ke discord

## Jawaban

### Installasi Jenkins via Docker

Banyak cara untuk installasi jenkins, cara yg umum seperti native bisa dilakukan tetapi kita wajib melalkukan installasi java (JDK, JRE) karena jenkins di bangun menggunakan java jadi butuh runtime tersebut. di contoh ini saya menggunakan docker compose untuk installasi jenkins nya dan saya juga menggunakan images official jenkins dari docker hub jadi tinggal eazy to use.

docker-compose.yaml

```yaml
services:
  jenkins:
    image: jenkins/jenkins:lts
    privileged: true
    user: root
    ports:
      - 8080:8080
      - 50000:50000
    container_name: jenkins
    volumes:
      - ./jenkins_configuration:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
```

tiggal jalankan sript tersebut:

```bash
docker compose up -d
```

Dan kita juga wajib buat memberikan reserve proxy dan ssl sertificate untuk si jenkins nya supaya aplikasi jenkins dapat berjalan dengan aman dan secure.

![Alt text](./images/1.%20Jenkins%20Reserve%20Proxy%20nginx%20proxymanager.png "img")

Cek kembali apakah aplikasi jenkins berjalan lancar atau tidak

![Alt text](./images/2.%20Jenkins%20Login%20success%20install%20jenkins.png "img")

Saat pertama kali install kita pilih yang suggested plugin dan kita buat admin baru
