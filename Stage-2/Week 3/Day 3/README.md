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

setiap ada perubahan code maka akan langsung ke auto trigger kalau di gitlab CI/CD dan langsung akan menjalankan pipeline

![Alt text](https://cdn.discordapp.com/attachments/1242141738857136178/1242295355404718080/image.png?ex=664d5135&is=664bffb5&hm=2661d2f93367b7f16647afafc3d7a66e88c7369103df777f14c9ec5aa58d097b&)

### Penjelasan pipeline

Pull dari repository
![Alt text](https://cdn.discordapp.com/attachments/1242141738857136178/1242295993047846932/image.png?ex=664d51cd&is=664c004d&hm=3a1e63ad0036db821441aa28557f8de69f0c5d8b4df7806d4ca3246b5ba58ecd&)

Dockerize/Build aplikasi kita
![Alt text](https://cdn.discordapp.com/attachments/1242141738857136178/1242296333415616512/image.png?ex=664d521e&is=664c009e&hm=68e7a12a00896ff5a77558af94cce3160e7f3ba9279a6d908caae176e0f4eb8e&)

Test application
![Alt text](https://cdn.discordapp.com/attachments/1242141738857136178/1242296375174234164/image.png?ex=664d5228&is=664c00a8&hm=805ca1eb9edfc15a99ebbac92604f3d456b9b36620716811fea20726996c3f5b&)

Deploy application
![Alt text](https://cdn.discordapp.com/attachments/1242141738857136178/1242296475954712647/image.png?ex=664d5240&is=664c00c0&hm=4ad45cb6927a7c0f1f1110bce380ee2d4ab0238a49777f2df77665a977ef4e79&)

push image ke docker hub
![Alt text](https://cdn.discordapp.com/attachments/1242141738857136178/1242296767605641306/image.png?ex=664d5286&is=664c0106&hm=4ccaa916716a0965a57c5551610f0c4449a6357ff964f4f217275b92dc364720&)

### GitlabCI notification to discord

![Alt text](https://cdn.discordapp.com/attachments/1242141738857136178/1242297690482675733/image.png?ex=664d5362&is=664c01e2&hm=f59610a94506f64362a28f91de55de3feb6d7b51320b9c7bd30174c259cec825&)

![Alt text](https://cdn.discordapp.com/attachments/1242141738857136178/1242297728692654151/image.png?ex=664d536b&is=664c01eb&hm=bd88950b6816e6fcfe689be844377a2ed653344b1107ef88d54da5afa1cc2b25&)

![Alt text](https://cdn.discordapp.com/attachments/1242141738857136178/1242298073074630739/image.png?ex=664d53bd&is=664c023d&hm=7f61115859ed07d0006be511951df9b3153b45f25a12ee8e75e51f7a8b003407&)
