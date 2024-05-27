# Tugas devops Dumbways Week 4 Stage 1

## DAY 2 Monitoring server with Grafana, Prometheus, Node_exporter

Tasks :

- Setup node-exporter, prometheus dan Grafana menggunakan docker
- install node-exporter di appserver & gateway
- Reverse Proxy
  - bebas ingin menggunakan nginx native / docker
  - Domain
    - exporter-$name.studentdumbways.my.id (node exporter)
    - prom-$name.studentdumbways.my.id (prometheus)
    - monitoring-$name.studentdumbways.my.id (grafana)
  - SSL Cloufflare on / certbot SSL biasa / wildcard SSL diperbolehkan
- Dengan Grafana, buatlah :
  - Dashboard untuk monitor resource server (CPU, RAM & Disk Usage) buatlah se freestyle kalian.
  - Buat dokumentasi tentang rumus `promql` yang kalian gunakan
  - Buat alerting dengan Contact Point pilihan kalian (discord, telegram, slack dkk)
  - Untuk alert :
    - Boleh menggunakan alert manager / alert rule dari grafana
    - Ketentuan alerting yang harus dibuat
      - CPU Usage over 20%
      - RAM Usage over 75%
  - Monitoring specific container
  - deploy application frontend di app-server - monitoring frontend container
- untuk alerting bisa di check di server discord yaa, sudah di buatkan channel alerting

## Jawaban

### Setup node-exporter, prometheus dan Grafana menggunakan docker

Untuk setup monitoring langkah pertama adalah diharuskan sudah punya docker & docker-compose karena semua nya berjalan ditas docker compose.

```yaml
services:
  grafana:
    image: grafana/grafana
    container_name: grafana
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - grafana-storage:/var/lib/grafana
  prometheus:
    image: docker.io/ubuntu/prometheus
    container_name: prometheus
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
    ports:
      - 9090:9090
    restart: unless-stopped
    volumes:
      - ./prometheus:/etc/prometheus
      - prom_data:/prometheus
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    restart: unless-stopped
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - "--path.procfs=/host/proc"
      - "--path.rootfs=/rootfs"
      - "--path.sysfs=/host/sys"
      - "--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)"
    expose:
      - 9100
volumes:
  grafana-storage: {}
  prom_data:
```

### install node-exporter di appserver & gateway

Tools monitoring seperti grafana dan prometheus cukup di satu vm atau server saja sedangkan node_exporter wajib di install disetiap vm yang mau dijadikan target untuk dimonitoring oleh karena itu berikut adalah contoh docker-compose.yaml khusus untuk vm target.

```yaml
services:
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    restart: unless-stopped
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - "--path.procfs=/host/proc"
      - "--path.rootfs=/rootfs"
      - "--path.sysfs=/host/sys"
      - "--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)"
    expose:
      - 9100
```

### Reserve Proxy

Untuk Reserve proxy di cloudflare saya menggunakan wild card SSL sertificate, dan juga untuk dns record nya, saya menggunakan cukup "\*.komar.studentdumbways.my.id" karena jika kita setup seperti ini maka semua subdomainnya tidak usah repot2 kita manage lagi.

![Alt text](https://cdn.discordapp.com/attachments/1243493123271950357/1243743425862307931/image.png?ex=665295d4&is=66514454&hm=8407eaa614715821ffca77e59aecfde5831bf6f6f87c918ba844c5d0f8cc9d41&)

konfigurasi dns record sepertini sudah bisa mencakup semua:

1. komar.studentdumbways.my.id
2. api.komar.studentdumbways.my.id
3. monitoring.komar.studentdumbways.my.id
4. prometheus.komar.studentdumbways.my.id
5. nodexp.komar.studentdumbways.my.id
6. dllllll

contoh salah satu configurasi reserve proxy:

```
server {
    listen 80;
    server_name prometheus.komar.studentdumbways.my.id;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name prometheus.komar.studentdumbways.my.id;

    ssl_certificate /etc/letsencrypt/live/komar.studentdumbways.my.id/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/komar.studentdumbways.my.id/privkey.pem;

    location / {
        proxy_pass http://30.111.325.127:9090;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

```

### Grafana dashboard

setelah kita setup reserve proxy di langkah sebelumnya kita tidak perlu lagi masuk ke grafana dengan ipaddress:port tetapi kita bisa langsung pakai domainnya, yaitu:

monitoring.komar.studentdumbways.my.id

![Alt text](https://cdn.discordapp.com/attachments/1243493123271950357/1243745414918967418/image.png?ex=665297ae&is=6651462e&hm=eb825b1393756a2f86f70ad054d7f5999bcaeae829c2a702fed50265377f3a0a&)

lalu setelah itu kita bisa langsung setup terlebih dahulu data source nya. dalam case ini adalah prometheus yang mengambilkan data dari semua node_exporternya yang sudah di setup terlebih dahulu di prometheus.yaml

![Alt text](https://cdn.discordapp.com/attachments/1243493123271950357/1243746724821073984/Screenshot_from_2024-05-25_09-03-36.png?ex=665298e6&is=66514766&hm=4893d58a07f2920f49e08945e50fd82168e0b7674a96002a404438bfd3116ffb&)

![Alt text](https://cdn.discordapp.com/attachments/1243493123271950357/1243747244843208855/image.png?ex=66529962&is=665147e2&hm=a7d17fc5d743acf99f17adf76a5281b9a33078f9bca4428433e1b94155c3402b&)
setelah semua yang di perlukan di setup langkah selanjutnya langsung saja membuat dashboard sesuai yang diinginkan dan menggunakan promQL sebagai query language nya.

![Alt text](https://cdn.discordapp.com/attachments/1243493123271950357/1243747830548660285/image.png?ex=665299ee&is=6651486e&hm=0e8d71e9a81c04f9941114d47c659416f1a759eec9cb69a17eb7e3e3be6831b3&)

![Alt text](https://cdn.discordapp.com/attachments/1243493123271950357/1243748112825319495/image.png?ex=66529a31&is=665148b1&hm=859fb6bea242ca5871b700b30c685c1df4cb76915dd9dfc3f21aa89f6b5f4961&)

### Dokumentasi rumus promQL

rumus cpu utilization:

```promql
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

rumus di atas adalah rumus untuk menghitung jumlah rata2 penggunaan cpu saat didalam mode idle dalam kurun waktu 5, dan dikalikan 100 supaya dapat melihat persentase nya dan terakhir di kurangi 100 supaya terlihat utilizationnya (1 core 2 thread) hasil outputnya adalah jumlah thead yang berjalan di saat mode idle.

![Alt text](https://cdn.discordapp.com/attachments/1243493123271950357/1243931005891383296/image.png?ex=66534486&is=6651f306&hm=97b8bdfc65b4230ef837fec1164ea3793d7d7f103fe40aa5a4443acdbd4cff28&)

![Alt text](https://cdn.discordapp.com/attachments/1243493123271950357/1243931748539174922/image.png?ex=66534537&is=6651f3b7&hm=1b7e32d9ca8d9aab9bce94be29e6a324c958cf0d94bff7641c2e5051b4473b82&)

![Alt text](https://cdn.discordapp.com/attachments/1243493123271950357/1243931801312034866/image.png?ex=66534544&is=6651f3c4&hm=4ae4192f4ed8d33147d17e2e82e0fc784b0b3ef5971feea265d1cac267b125d3&)

![Alt text](https://cdn.discordapp.com/attachments/1243493123271950357/1243931876360716379/image.png?ex=66534556&is=6651f3d6&hm=98cfa6cfc8429caf9af036443ab5e571fda68a778b919301d0a0d071b3239776&)

rumus memory utilization:

```promql
100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))
```

rumus diatas adalah rumus untuk menghitung persentase dari jumlah memory yang digunakan dengan membagu memory available dengan memory total setelah itu dikurangi dengan 1 maka akan menampilkan hasil penggunaan memory, lalu dikalikan dengan 100 supaya mendapatkan hasil presentasenya

![Alt text](https://cdn.discordapp.com/attachments/1243493123271950357/1243933351447101450/image.png?ex=665346b6&is=6651f536&hm=1a5756c0c4d806448037c20ab41836302fc1d27c1428c295ac937309ccc7de36&)

### Allerting grafana

### Monitoring container Cadvisor
