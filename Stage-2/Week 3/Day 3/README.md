# Tugas devops Dumbways Week 3 Stage 2

## DAY 3 CI/CD with Gitlab

Tasks :
[ Gitlab ]

- Buat akun di gitlab.com
- push SCM kalian dari local-server ke gitlab
- Buatlah beberapa Job menggunakan gitlabci untuk aplikasi kalian
  - Job Frontend
  - Untuk script CICD atur flow pengupdate an aplikasi se freestyle kalian dan harus mencangkup
    - Pull dari repository
    - Dockerize/Build aplikasi kita
    - push image ke docker hub
    - Test application
    - pull new image
    - Deploy application
- GitlabCI notification to discord

## JAWABAN

### Buat akun di gitlab.com

![Alt text](https://cdn.discordapp.com/attachments/1242141738857136178/1242143535973793892/image.png?ex=664cc3d0&is=664b7250&hm=5075146a90fdd9593790edce2f0122a7454dff1b8df0b210186e5b2fa957eb46&)

### push SCM kalian dari local-server ke gitlab

![Alt text](https://cdn.discordapp.com/attachments/1242141738857136178/1242143123442761799/image.png?ex=664cc36e&is=664b71ee&hm=6ee73676c128a98a2cc0a5ea907dfdd0c87ce61e402dbf12d0997a3809007f77&)

![Alt text](https://cdn.discordapp.com/attachments/1242141738857136178/1242142875534233640/image.png?ex=664cc333&is=664b71b3&hm=89c432d92958f30a24628047cc3a699d80d29fb4c1b40d60563c2a5f1bc61252&)

### Buatlah beberapa Job menggunakan gitlabci untuk aplikasi kalian Job Frontend

```yaml
stages:
  - pull
  - build
  - test
  - deploy
  - push

pull_image:
  stage: pull
  before_script:
    - chmod 400 $SSH_PRIVATE_KEY
  script:
    - ssh -o StrictHostKeyChecking=no -i $SSH_PRIVATE_KEY $USERNAME@$BUILD_HOST "
      cd $WORKDIR &&
      git pull"

build_image:
  stage: build
  before_script:
    - chmod 400 $SSH_PRIVATE_KEY
  script:
    - ssh -o StrictHostKeyChecking=no -i $SSH_PRIVATE_KEY $USERNAME@$BUILD_HOST "
      cd $WORKDIR &&
      docker build -t $DOCKER_IMAGE -f Dockerfile-prod . "

test_images:
  stage: test
  before_script:
    - chmod 400 $SSH_PRIVATE_KEY
  script:
    - ssh -o StrictHostKeyChecking=no -i $SSH_PRIVATE_KEY $USERNAME@$BUILD_HOST "
      docker run -d -p 3005:80 --name testconn $DOCKER_IMAGE &&
      if wget -q --spider http://127.0.0.1:3005/; then echo 'Website up'; else echo 'Website down'; fi &&
      docker stop testconn &&
      docker rm testconn"

deploy:
  stage: deploy
  before_script:
    - chmod 400 $SSH_PRIVATE_KEY
  script:
    - ssh -o StrictHostKeyChecking=no -i $SSH_PRIVATE_KEY $USERNAME@$BUILD_HOST "
      cd $DEPLOY_DIR &&
      docker compose -f docker-compose-frontend.yaml down &&
      docker compose -f docker-compose-frontend.yaml up -d"

push_image:
  stage: push
  image: docker:latest
  services:
    - docker:dind
  variables:
    DOCKER_TLS_CERTDIR: "/certs"
  before_script:
    - docker login -u $DOCKER_REGISTRY_USERNAME -p $DOCKER_REGISTRY_PASSWORD
  script:
    - docker build -t $DOCKER_IMAGE -f Dockerfile-prod .
    - docker push $DOCKER_IMAGE
```

![Alt text]()
![Alt text]()
![Alt text]()
![Alt text]()
![Alt text]()

### Penjelasan pipeline

![Alt text]()
![Alt text]()
![Alt text]()
![Alt text]()
![Alt text]()

Pull dari repository
Dockerize/Build aplikasi kita
push image ke docker hub
Test application
pull new image
Deploy application
GitlabCI notification to discord
