# Tugas devops Dumbways Week 3 Stage 2

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

### Setup SSH-KEY di local server jenkins kalian, agar dapat login ke dalam server menggunakan SSH-KEY

![Alt text](https://media.discordapp.net/attachments/1242113758919131197/1242114574476640337/9.png?ex=664ca8d7&is=664b5757&hm=60919db81e6a1c2543230af2921d7e2116d9b727fb6f1cc6d058aa3a99c0f467&=&format=webp&quality=lossless&width=1179&height=663)

setelah kita generate ssh keys, kita wajib menambahkan publik keys di authorized_keys, dengan perintah:

```bash
echo id_rsa.pub >> authorize_keys
```

simpan Private keys nya di jenkin credential

![Alt text](https://media.discordapp.net/attachments/1242113758919131197/1242114574023524392/10.png?ex=664ca8d7&is=664b5757&hm=f415543004a651d7cb7368cc23051624efaa6889cc2e60a87b86a4abcebee242&=&format=webp&quality=lossless&width=1179&height=663)

### Reverse Proxy Jenkins

untuk membuat reserve_proxy di jenkins kita wajib melihat dokumentasi resmi jenkins dan kita copy reserve_proxy.conf di jenkins docs:

```conf
upstream jenkins {
  keepalive 32; # keepalive connections
  server 127.0.0.1:8080; # jenkins ip and port
}

# Required for Jenkins websocket agents
map $http_upgrade $connection_upgrade {
  default upgrade;
  '' close;
}

server {
  listen          80;       # Listen on port 80 for IPv4 requests
  listen 443 ssl;
  server_name     pipeline-team2.studentdumbways.my.id;  # replace 'jenkins.example.com' with your server domain name
  ssl_certificate /etc/letsencrypt/live/pipeline-team2.studentdumbways.my.id/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/pipeline-team2.studentdumbways.my.id/privkey.pem;


  # this is the jenkins web root directory
  # (mentioned in the output of "systemctl cat jenkins")
  root            /var/run/jenkins/war/;

  access_log      /var/log/nginx/jenkins.access.log;
  error_log       /var/log/nginx/jenkins.error.log;

  # pass through headers from Jenkins that Nginx considers invalid
  ignore_invalid_headers off;

  location ~ "^/static/[0-9a-fA-F]{8}\/(.*)$" {
    # rewrite all static files into requests to the root
    # E.g /static/12345678/css/something.css will become /css/something.css
    rewrite "^/static/[0-9a-fA-F]{8}\/(.*)" /$1 last;
  }

  location /userContent {
    # have nginx handle all the static requests to userContent folder
    # note : This is the $JENKINS_HOME dir
    root /var/lib/jenkins/;
    if (!-f $request_filename){
      # this file does not exist, might be a directory or a /**view** url
      rewrite (.*) /$1 last;
      break;
    }
    sendfile on;
  }

  location / {
      sendfile off;
      proxy_pass         http://jenkins;
      proxy_redirect     default;
      proxy_http_version 1.1;

      # Required for Jenkins websocket agents
      proxy_set_header   Connection        $connection_upgrade;
      proxy_set_header   Upgrade           $http_upgrade;

      proxy_set_header   Host              $http_host;
      proxy_set_header   X-Real-IP         $remote_addr;
      proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
      proxy_set_header   X-Forwarded-Proto $scheme;
      proxy_max_temp_file_size 0;

      #this is the maximum upload size
      client_max_body_size       10m;
      client_body_buffer_size    128k;

      proxy_connect_timeout      90;
      proxy_send_timeout         90;
      proxy_read_timeout         90;
      proxy_request_buffering    off; # Required for HTTP CLI commands
  }

}
```

domain ex. pipeline-team1.studentdumbways.my.id

### Job CI/CD aplikasi wayshub backend menggunakan Jenkins

untuk membuat job kita wajib push repository ke github lalu kita masukan ke bagian jenkins job, pilih yang pipeline

![Alt text](https://media.discordapp.net/attachments/1242113758919131197/1242114664972681236/13.png?ex=664ca8ed&is=664b576d&hm=abd365434f86ae4f2d3fc052cd368584b6fe5ee0e97df605cd35d4b90b02dd68&=&format=webp&quality=lossless&width=1179&height=663)

contoh pipeline sederhana:

```Jenkinsfile
def secret = 'vm'
def branch = 'master'
def serverCredentialsId = 'server'
def directoryCredentialsId = 'directory'
def dockerLoginCredentialsId = 'docker-login'
def nameBuildCredentialsId = 'namebuild'
def discordurlCredentialsId = 'discord-webhook-url'
def appurlCredentialsId = 'app-url'

pipeline {
    agent any
    environment {
	SERVER = credentials("${serverCredentialsId}")
	DIRECTORY = credentials("${directoryCredentialsId}")
	DOCKERLOGIN = credentials("${dockerLoginCredentialsId}")
	NAMEBUILD = credentials("${nameBuildCredentialsId}")
	DISCORD_WEBHOOK_URL = credentials("${discordurlCredentialsId}")
	APPURL = credentials("${appurlCredentialsId}")
    }
    stages {
        stage ('pull new code') {
            steps {
                sshagent([secret]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${SERVER} << EOF
                            cd ${DIRECTORY}
                            git pull origin ${branch}
                            echo "Selesai Pulling!"
                            exit
                        EOF
                    """
                }
            }
        }
	stage('Pull Notifier') {
            steps {
                script {
                    discordSend description: 'Pull notif',
                                footer: 'Pull code from github berhasil',
                                image: 'https://t4.ftcdn.net/jpg/00/88/85/97/360_F_88859742_3pcsH0QNgseXjj2Y8HeZSXJbHUb19bx2.jpg',
                                link: env.BUILD_URL,
                                result: currentBuild.currentResult,
                                scmWebUrl: 'https://github.com/komarkun/wayshub-backend-komar.git',
                                thumbnail: 'https://cdn.discordapp.com/attachments/1241391101848322081/1242064109566951485/KomarKUN.png?ex=664c79d8&is=664b2858&hm=0321fbe451c67094d13a0f471d48ae4be8b25feb14f3ae0a23000ec0e29e7d59&',
                                title: env.JOB_NAME,
                                webhookURL: DISCORD_WEBHOOK_URL
                }
            }
        }

        stage ('build the code') {
            steps {
                sshagent([secret]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${SERVER} << EOF
                            cd ${DIRECTORY}
                            docker build -t ${NAMEBUILD} .
                            echo "Selesai Building!"
                            exit
                        EOF
                    """
                }
            }
        }
	stage('Build Notifier') {
            steps {
                script {
                    discordSend description: 'Build Notif',
                                footer: 'Build Berhasill',
                                image: 'https://t4.ftcdn.net/jpg/00/88/85/97/360_F_88859742_3pcsH0QNgseXjj2Y8HeZSXJbHUb19bx2.jpg',
                                link: env.BUILD_URL,
                                result: currentBuild.currentResult,
                                scmWebUrl: 'https://github.com/komarkun/wayshub-backend-komar.git',
                                thumbnail: 'https://cdn.discordapp.com/attachments/1241391101848322081/1242064109566951485/KomarKUN.png?ex=664c79d8&is=664b2858&hm=0321fbe451c67094d13a0f471d48ae4be8b25feb14f3ae0a23000ec0e29e7d59&',
                                title: env.JOB_NAME,
                                webhookURL: DISCORD_WEBHOOK_URL
                }
            }
        }

	stage('Test the app') {
            steps {
                sshagent([secret]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${SERVER} << EOF
                            wget --spider --timeout=30 --tries=1 ${APPURL}
                            echo "Selesai Testing!"
                            exit
                        EOF
                    """
                }
            }
        }
	stage('Test Notifier') {
            steps {
                script {
                    discordSend description: 'Test Notif',
                                footer: 'Runs test wget spider berhasil',
                                image: 'https://t4.ftcdn.net/jpg/00/88/85/97/360_F_88859742_3pcsH0QNgseXjj2Y8HeZSXJbHUb19bx2.jpg',
                                link: env.BUILD_URL,
                                result: currentBuild.currentResult,
                                scmWebUrl: 'https://github.com/komarkun/wayshub-backend-komar.git',
                                thumbnail: 'https://cdn.discordapp.com/attachments/1241391101848322081/1242064109566951485/KomarKUN.png?ex=664c79d8&is=664b2858&hm=0321fbe451c67094d13a0f471d48ae4be8b25feb14f3ae0a23000ec0e29e7d59&',
                                title: env.JOB_NAME,
                                webhookURL: DISCORD_WEBHOOK_URL
                }
            }
        }

        stage ('deploy') {
            steps {
                sshagent([secret]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${SERVER} << EOF
                            cd ${DIRECTORY}
                            cd ../
                            docker compose -f docker-compose-backend.yaml down
                            docker compose -f docker-compose-backend.yaml up -d
                            echo "Selesai Men-Deploy!"
                            exit
                        EOF
                    """
                }

            }
        }
	stage('Deploy Notifier') {
            steps {
                script {
                    discordSend description: 'Deploy Notif',
                                footer: 'deploy di server berhasil',
                                image: 'https://t4.ftcdn.net/jpg/00/88/85/97/360_F_88859742_3pcsH0QNgseXjj2Y8HeZSXJbHUb19bx2.jpg',
                                link: env.BUILD_URL,
                                result: currentBuild.currentResult,
                                scmWebUrl: 'https://github.com/komarkun/wayshub-backend-komar.git',
                                thumbnail: 'https://cdn.discordapp.com/attachments/1241391101848322081/1242064109566951485/KomarKUN.png?ex=664c79d8&is=664b2858&hm=0321fbe451c67094d13a0f471d48ae4be8b25feb14f3ae0a23000ec0e29e7d59&',
                                title: env.JOB_NAME,
                                webhookURL: DISCORD_WEBHOOK_URL
                }
            }
        }
	stage ('Push to Docker Hub') {
            steps {
                sshagent([secret]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${SERVER} << EOF
                            cd ${DIRECTORY}
			    ${DOCKERLOGIN}
			    docker push ${NAMEBUILD}
                            echo "Selesai Push Images To Docker Registries"
                            exit
                        EOF
                    """
                }

            }
        }

	stage('Push Notifier') {
            steps {
                script {
                    discordSend description: 'Push Notif',
                                footer: 'Berhasil push ke docker hub',
                                image: 'https://t4.ftcdn.net/jpg/00/88/85/97/360_F_88859742_3pcsH0QNgseXjj2Y8HeZSXJbHUb19bx2.jpg',
                                link: env.BUILD_URL,
                                result: currentBuild.currentResult,
                                scmWebUrl: 'https://github.com/komarkun/wayshub-backend-komar.git',
                                thumbnail: 'https://cdn.discordapp.com/attachments/1241391101848322081/1242064109566951485/KomarKUN.png?ex=664c79d8&is=664b2858&hm=0321fbe451c67094d13a0f471d48ae4be8b25feb14f3ae0a23000ec0e29e7d59&',
                                title: env.JOB_NAME,
                                webhookURL: DISCORD_WEBHOOK_URL
                }
            }
        }

    }
}

```

![Alt text](https://media.discordapp.net/attachments/1242113758919131197/1242114663521587350/15.png?ex=664ca8ed&is=664b576d&hm=d618a4d4f3abf5899b0379e134592012b88293659ab7e5bdfbe22eaa9f01fb9c&=&format=webp&quality=lossless&width=1179&height=663)

### Penjelasan pipeline

Pull dari repository github
![Alt text](https://cdn.discordapp.com/attachments/1242113758919131197/1242137982283284573/image.png?ex=664cbea4&is=664b6d24&hm=35e9e5a4d2e855aeb73841005d04373076ca66a42355c0731591b1b6ffb9f7ee&)

Dockerize/Build aplikasi kita
![Alt text](https://cdn.discordapp.com/attachments/1242113758919131197/1242138199946690721/image.png?ex=664cbed8&is=664b6d58&hm=7ba70f1e925d44a7f7252133d7ef20679d3778422d9e8443377405dbe1d74700&)

Test application
![Alt text](https://cdn.discordapp.com/attachments/1242113758919131197/1242138499981905940/image.png?ex=664cbf20&is=664b6da0&hm=71b93a30f9171fbc8d9430b7103749552b407cc860bdc7a24a00d76f96b9a58a&)

Deploy aplikasi on top Docker
![Alt text](https://cdn.discordapp.com/attachments/1242113758919131197/1242138831386443896/image.png?ex=664cbf6f&is=664b6def&hm=3b50cfca67c982e712b55c29378478dc036d799488395a4e8c1b8225ca02b3f4&)

Push ke Docker Hub
![Alt text](https://cdn.discordapp.com/attachments/1242113758919131197/1242139099855454208/image.png?ex=664cbfaf&is=664b6e2f&hm=d7f8403dcd30ff7696bfd1f906e97b8f610362503c6e94d585fc830f4a304c70&)

### Auto trigger setiap ada perubahan di SCM

untuk membuat auto trigger kita wajib menambahkan url jenkins ke github repository kita di menu webhooks
![Alt text](https://cdn.discordapp.com/attachments/1242113758919131197/1242139465292714074/image.png?ex=664cc006&is=664b6e86&hm=a801ff854bf6607f39eb5bb4a7d169a2a2e0fab8081510981548c2a2a05f756d&)

### Buat job notification ke discord

untuk membuat job notifier di jenkins kita wajib menambahkan webhook url jenkins kita ke pipeline nya jadi setiap ada push nanti kita bsia melihat notifnya di discord.

```
stage('Test Notifier') {
            steps {
                script {
                    discordSend description: 'Test Notif',
                                footer: 'Runs test wget spider berhasil',
                                image: 'https://t4.ftcdn.net/jpg/00/88/85/97/360_F_88859742_3pcsH0QNgseXjj2Y8HeZSXJbHUb19bx2.jpg',
                                link: env.BUILD_URL,
                                result: currentBuild.currentResult,
                                scmWebUrl: 'https://github.com/komarkun/wayshub-backend-komar.git',
                                thumbnail: 'https://cdn.discordapp.com/attachments/1241391101848322081/1242064109566951485/KomarKUN.png?ex=664c79d8&is=664b2858&hm=0321fbe451c67094d13a0f471d48ae4be8b25feb14f3ae0a23000ec0e29e7d59&',
                                title: env.JOB_NAME,
                                webhookURL: DISCORD_WEBHOOK_URL
                }
            }
        }
```

![Alt text](https://cdn.discordapp.com/attachments/1242113758919131197/1242114777161924648/23.png?ex=664ca908&is=664b5788&hm=b52049371dff6d7761fd179aa7b40cd641bc8649f9013c815819629d89f6efef&)

![Alt text](https://cdn.discordapp.com/attachments/1242113758919131197/1242114776725979206/24.png?ex=664ca908&is=664b5788&hm=b9a68918882f9eb5fb38225494f0711666c95dd1c937a49dad21a62efcb29995&)
![Alt text](https://cdn.discordapp.com/attachments/1242113758919131197/1242114777581486181/22.png?ex=664ca908&is=664b5788&hm=e5e4cc38f02552be84c5069128d218865912d72ce1f8dd7debbd9218f87e4b30&)
