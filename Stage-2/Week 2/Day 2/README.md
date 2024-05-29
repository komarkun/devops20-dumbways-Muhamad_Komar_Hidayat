# Tugas devops Dumbways Week 2 Stage 2

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

![Alt text](./images/1.%20atur%20ssh%20key%20pairs.png)

setelah kita generate ssh keys, kita wajib menambahkan publik keys di authorized_keys, dengan perintah:

```bash
echo id_rsa.pub >> authorize_keys
```

simpan Private keys nya di jenkin credential

![Alt text](./images/2.%20atur%20credentials.png)

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

![Alt text](./images/3.%20buat%20pipeline.png)

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

![Alt text](./images/4.%20contoh%20pipeline.png)

### Penjelasan pipeline

Pull dari repository github
![Alt text](./images/5.%20pull%20new%20code.png)

Dockerize/Build aplikasi kita
![Alt text](./images/6.%20build%20new%20code.png)

Test application
![Alt text](./images/7.%20testcode%20.png)

Deploy aplikasi on top Docker
![Alt text](./images/8.%20deploy%20new%20code.png)

Push ke Docker Hub
![Alt text](./images/9.%20push%20docker%20hub.png)

### Auto trigger setiap ada perubahan di SCM

untuk membuat auto trigger kita wajib menambahkan url jenkins ke github repository kita di menu webhooks
![Alt text](./images/10.%20webhook%20trigger.png)

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

![Alt text](./images/11.%20wasyhub%20backedn%20pipeline.png)

![Alt text](./images/12.%20notif%201.png)
![Alt text](./images/13.%20notif%202.png)
