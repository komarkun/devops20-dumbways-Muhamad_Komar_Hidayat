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

![Alt text](./images/1.%20dns%20records.png)

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

![Alt text](./images/2.%20monitoring%20grafana.png)

lalu setelah itu kita bisa langsung setup terlebih dahulu data source nya. dalam case ini adalah prometheus yang mengambilkan data dari semua node_exporternya yang sudah di setup terlebih dahulu di prometheus.yaml

![Alt text](./images/3.%20prometheus.png)

![Alt text](./images/4.%20prometheus%20.png)
setelah semua yang di perlukan di setup langkah selanjutnya langsung saja membuat dashboard sesuai yang diinginkan dan menggunakan promQL sebagai query language nya.

![Alt text](./images/5.%20monitorings.png)

![Alt text](./images/6.%20monitorings.png)

### Dokumentasi rumus promQL

rumus cpu utilization:

```promql
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

rumus di atas adalah rumus untuk menghitung jumlah rata2 penggunaan cpu saat didalam mode idle dalam kurun waktu 5, dan dikalikan 100 supaya dapat melihat persentase nya dan terakhir di kurangi 100 supaya terlihat utilizationnya (1 core 2 thread) hasil outputnya adalah jumlah thead yang berjalan di saat mode idle.

![Alt text](./images/7.%20graph.png)

![Alt text](./images/8.%20graph%202.png)

![Alt text](./images/9.%20graph%203.png)

![Alt text](./images/10.%20graph%204.png)

rumus memory utilization:

```promql
100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))
```

rumus diatas adalah rumus untuk menghitung persentase dari jumlah memory yang digunakan dengan membagu memory available dengan memory total setelah itu dikurangi dengan 1 maka akan menampilkan hasil penggunaan memory, lalu dikalikan dengan 100 supaya mendapatkan hasil presentasenya

![Alt text](./images/11.%20cpus-memory.png)

### Allerting grafana

### Monitoring container Cadvisor
