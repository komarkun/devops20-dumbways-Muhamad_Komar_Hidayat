# Tugas devops Dumbways Week 4 Stage 2

## DAY 1 Terraform with cloud provider (Google Cloud / GCP)

Task:

Dengan mendaftar akun free tier AWS/GCP/Azure, buatlah Infrastructre dengan terraform menggunakan registry yang sudah ada. (spec menyesuaikan saja dengan free tier yang di dapatkan)

## JAWABAN

Untuk membuat Infrastructure as code (terraform in GCP) sangat wajib untuk punya google accout yang sudah terhubung ke google cloud console dan sudah punya billing juga baik yang free trial $300 maupun yang sudah berbayar. dan langkah selanjutnya adalah membuat projek di dalam GCP supaya kita bisa membuat infrastructure, dalam case ini adalah infrastructure google compute engine untuk membuat server (virtual machine).

![Alt text](https://cdn.discordapp.com/attachments/1243016181124825118/1243018162128289882/Project_in_GCP.png?ex=664ff260&is=664ea0e0&hm=17f8d716d1fe7b7fb3fba490869fa5eda49cb1dc5243e4a2de500e4816bec93d&)

Setelah kita membuat project di GCP langkah selanjutnya adalah kita buat service account agar terraform kita bisa terkoneksi ke GCP dan pastikan tidak boleh terekspose oleh yg tidak berkepentingan karena BERBAHAYA.

![Alt text](https://cdn.discordapp.com/attachments/1243016181124825118/1243020609479508018/create_service_account.png?ex=664ff4a7&is=664ea327&hm=af05a8a2c20c54f70cbeb59656b2b5747e67f074372d0e7239913930c08107cf&)

Jangan lupa menambahkan role nya, bisa spesific untuk satu service (Google Compute Engine) saja atau semua service dengan mengklik pilihan owner.

![Alt text](https://media.discordapp.net/attachments/1243016181124825118/1243020609819115561/image.png?ex=664ff4a7&is=664ea327&hm=8f7c0d85aadd6b036dcc7014da11e263ef40616b2783c8d350adb1d03fe51079&=&format=webp&quality=lossless&width=1380&height=663)

Setelah itu kita buat API keys nya dan jangan di ekspose siapapun, format file nya JSON yang akan otomatis di download di file kita

![Alt text](https://media.discordapp.net/attachments/1243016181124825118/1243020610162921552/image.png?ex=664ff4a7&is=664ea327&hm=76517da4177487c94480f6928121731a602c1d0e0391787957829179d873b956&=&format=webp&quality=lossless&width=1380&height=663)

Setelah semua dependensy yang di perlukan di google cloud telah berhasil disetting langkah selanjutnya kita bisa langsung ke terraform. dengan melakukan installasi terlebih dahulu. disini saya menggunakan Homebrew.

Link Installasi Terraform

```
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
```

![Alt text](https://cdn.discordapp.com/attachments/1243016181124825118/1243022357828997232/image.png?ex=664ff648&is=664ea4c8&hm=d32e6dee228b33aabb439756ec30137001391ae678011e2095ad38a10ac29cea&)

setelah terraform terrinstall kita bisa membuat directory structure supaya lebih rapih yang berisikan semua konfigurasi dari terraform kita.

![Alt text](https://cdn.discordapp.com/attachments/1243016181124825118/1243041877930803261/Directory_structure_terraform.png?ex=66500876&is=664eb6f6&hm=cf8c21a7f8804c4f6464ead8bc939885f2b3f4a222c2c5024b223f6df18ced44&)

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

![Alt text](https://cdn.discordapp.com/attachments/1243016181124825118/1243040509497446410/image.png?ex=66500730&is=664eb5b0&hm=bd8e3cd4a1b6454a1f669492b6c8b49f96d5ce10525b2857029e8da18cdf1945&)

![Alt text](https://cdn.discordapp.com/attachments/1243016181124825118/1243040677340905512/image.png?ex=66500758&is=664eb5d8&hm=80f2584c1cda4b3a52adbda78f958873d3ba21b0da79a86f1ed96eaba23bc597&)

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
![Alt text](https://cdn.discordapp.com/attachments/1243016181124825118/1243034245702750300/image.png?ex=6650015a&is=664eafda&hm=918ff5fbebc9b88850b13239a2347e27e3b08c2d55058221609b0285781d4bc1&)

validasi jika ada kesalahan kode
![Alt text](https://cdn.discordapp.com/attachments/1243016181124825118/1243037109044908083/image.png?ex=66500405&is=664eb285&hm=1d37b36a94795a6d36be47809f4f5fb975947b852521d78d209a69ce47a721b2&)

cek terlebih dahulu planning yang akan dibuat
![Alt text](https://media.discordapp.net/attachments/1243016181124825118/1243037338490376313/image.png?ex=6650043c&is=664eb2bc&hm=44df058eb74410fe3942145e6fb2e63df4f1de641221e23ae1c81a4cee228849&=&format=webp&quality=lossless&width=1179&height=663)
![Alt text](https://media.discordapp.net/attachments/1243016181124825118/1243037338905350234/image.png?ex=6650043c&is=664eb2bc&hm=e4ace8f1eec25b081e669dbcba51ea93c0eb3e21e214c83fbc00f3c074690dd2&=&format=webp&quality=lossless&width=1179&height=663)

jalankan terraform apply untuk mulai membuat instance secara IAC (infrastructure as code)

![Alt text](https://cdn.discordapp.com/attachments/1243016181124825118/1243039595973836900/image.png?ex=66500656&is=664eb4d6&hm=e0f5f0f81eff48d567b0c6c9e996a86ddd33bd500241b9a8b5a34174b3dc0954&)
![Alt text](https://cdn.discordapp.com/attachments/1243016181124825118/1243039768175186000/image.png?ex=6650067f&is=664eb4ff&hm=540d1a8dfe11c5f495903643b69252a8916835440d2ec9f148d0da0bb9e96cbb&)

Tunggu command terraform di cls selesai, jika sudah selesai dan success maka virtual machine kita di compute engine google cloud maka akan terbuat sesuai jumlahnya

![Alt text](https://cdn.discordapp.com/attachments/1243016181124825118/1243040839337381988/Screenshot_from_2024-05-23_10-17-03.png?ex=6650077e&is=664eb5fe&hm=5c7c5ec876f1fcdd144cab074a045bce22282d23daa53cb64409ec00f9affcc9&)

(Opsional) kita bisa menjalankan perintah destroy untuk menghapus semua instance jika sudah kita tidak gunakan
![Alt text](https://media.discordapp.net/attachments/1243016181124825118/1243042949001121863/image.png?ex=66500975&is=664eb7f5&hm=1b28402e8e3337e497917425d665fb16cef4acba37964899f714cabf23b7e457&=&format=webp&quality=lossless&width=1179&height=663)
![Alt text](https://media.discordapp.net/attachments/1243016181124825118/1243042948539486310/image.png?ex=66500975&is=664eb7f5&hm=ee3ff6a1c2a70fed824fa1c47a82403402608e4fb722b6c7c3187e575527b439&=&format=webp&quality=lossless&width=1179&height=663)

![Alt text](https://media.discordapp.net/attachments/1243016181124825118/1243146796369186836/Terraform_success.png?ex=66506a2c&is=664f18ac&hm=db881b4aaa993a51e41062eb3575b33ae0ef93da3cf37402abad2f4e1599ca21&=&format=webp&quality=lossless&width=1380&height=663)
