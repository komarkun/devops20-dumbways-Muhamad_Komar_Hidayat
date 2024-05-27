# Tugas devops Dumbways Week 4 Stage 2

## DAY 1 Terraform with cloud provider (Google Cloud / GCP)

Task:

Dengan mendaftar akun free tier AWS/GCP/Azure, buatlah Infrastructre dengan terraform menggunakan registry yang sudah ada. (spec menyesuaikan saja dengan free tier yang di dapatkan)

## JAWABAN

Untuk membuat Infrastructure as code (terraform in GCP) sangat wajib untuk punya google accout yang sudah terhubung ke google cloud console dan sudah punya billing juga baik yang free trial $300 maupun yang sudah berbayar. dan langkah selanjutnya adalah membuat projek di dalam GCP supaya kita bisa membuat infrastructure, dalam case ini adalah infrastructure google compute engine untuk membuat server (virtual machine).

![Alt text](./images/1.%20Project_in_GCP.png)

Setelah kita membuat project di GCP langkah selanjutnya adalah kita buat service account agar terraform kita bisa terkoneksi ke GCP dan pastikan tidak boleh terekspose oleh yg tidak berkepentingan karena BERBAHAYA.

![Alt text](./images/2.%20create_service_account.png)

Jangan lupa menambahkan role nya, bisa spesific untuk satu service (Google Compute Engine) saja atau semua service dengan mengklik pilihan owner.

![Alt text](./images/3.%20create_service_account.png)

Setelah itu kita buat API keys nya dan jangan di ekspose siapapun, format file nya JSON yang akan otomatis di download di file kita

![Alt text](./images/4.%20create_service_account.png)

Setelah semua dependensy yang di perlukan di google cloud telah berhasil disetting langkah selanjutnya kita bisa langsung ke terraform. dengan melakukan installasi terlebih dahulu. disini saya menggunakan Homebrew.

Link Installasi Terraform

```
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
```

![Alt text](./images/5.%20home%20brew%20terraform.png)

setelah terraform terrinstall kita bisa membuat directory structure supaya lebih rapih yang berisikan semua konfigurasi dari terraform kita.

![Alt text](./images/tree%20terraform.png)

### Penjelasan Directorry structure

agar semakin rapih jangan simpan semua konfigurasi terraform di main.tf file tapi lebih baik kita pisah pisah sesuai dengan fungsinnya.

File pertama dan yang sangat wajib disini adalah file API keys yang berformat JSON file yang telah kita download di google cloude, Lokasinya = "I AM admin/Service account" Wajib di sesuai kan masing masing lah

### Keys.json

```JSON
{
  "type": "service_account",
  "project_id": "",
  "private_key_id": "",
  "private_key": "",
  "client_email": "",
  "client_id": "",
  "auth_uri": "",
  "token_uri": "",
  "auth_provider_x509_cert_url": "",
  "client_x509_cert_url": "",
  "universe_domain": "googleapis.com"
}

```

File yang sangat wajib kedua adalah main.tf, kita bisa menaruh semua konfigurasi langsung di satu file ini saja, tapi rekomendasinya adalah kita pisah pisah

#### main.tf

```tf
resource "google_compute_instance" "instance_1" {
  name                      = "terraform-debian-1"
  machine_type              = "f1-micro"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}

resource "google_compute_instance" "instance_2" {
  name                      = "terraform-debian-2"
  machine_type              = "e2-micro"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}

resource "google_compute_instance" "instance_3" {
  name                      = "terraform-debian-3"
  machine_type              = "e2-micro"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}
```

Kita wajib lihat dan baca terlebih dahulu spesifikasi dari google cloud nya di laman resmi nya langsung yaitu

```
# GCP
https://cloud.google.com/compute/all-pricing

# Terraform
https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_instance#boot_disk
```

![Alt text](./images/8.%20tier%20harga%20google%20cloud.png)

![Alt text](./images/9.%20tier%20harga%20google%20cloud.png)

#### provider.tf

```tf
provider "google" {
  credentials = file(var.gcp_svc_key)
  project = var.gcp_project
  region = var.gcp_region
  zone = var.gcp_zone
}
```

#### terraform.tfvars

```tf
gcp_svc_key = "./keys.json"
gcp_project = "google-projectid"
gcp_region = "asia-souteast2"
gcp_zone = "asia-souteast2-a"
```

### Runs Terraform command

Setelah semua konfigurasi kita setup kita langsung aja tampa basa basi jalankan perintah terraform nya. wajib dimual dari terraform init, supaya kita menginisialisasi provider nya terlebih dahulu dalam case ini google cloud

```bash
# inisialisasi terraform
terraform init

# memvalidasi script terraform
terraform validate

# check planning untuk memastikan
terraform plan

# apply atau jalankan semua planning state
terraform apply

# mematikan semua service jika sudah selesai dan tidak terpakai
terraform destroy
```

init sialisasi dulu untuk pertama kali
![Alt text](./images/6.%20terraform%20init.png)

validasi jika ada kesalahan kode
![Alt text](./images/7.%20terraform%20validate.png)

cek terlebih dahulu planning yang akan dibuat
![Alt text](./images/10.%20terraform%20plan.png)
![Alt text](./images/11.%20terraform%20plan.png)

jalankan terraform apply untuk mulai membuat instance secara IAC (infrastructure as code)

![Alt text](./images/12.%20terraform%20apply.png)

![Alt text](./images/13.%20terraform%20apply.png)

Tunggu command terraform di cls selesai, jika sudah selesai dan success maka virtual machine kita di compute engine google cloud maka akan terbuat sesuai jumlahnya

![Alt text](./images/14.%20check%20instance.png)

(Opsional) kita bisa menjalankan perintah destroy untuk menghapus semua instance jika sudah kita tidak gunakan
![Alt text](./images/15.%20terraform%20destroy.png)
![Alt text](./images/16.%20terraform%20destroy.png)

![Alt text](./images/17.%20sucsess.png)
