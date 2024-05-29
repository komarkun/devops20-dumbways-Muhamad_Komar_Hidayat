resource "google_compute_instance" "terraform-ubuntu-1" {
  name                      = "appserver"
  machine_type              = "e2-micro"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.gcp_images
    }
  }

  network_interface {
    network = "default"         # default network vpc 
    access_config {}
  }
  tags = ["go"]                 # firewall custom name : go = allow all ip
  metadata = {
    ssh_keys       = "komarhidayat0:${file("~/.ssh/gcloud-vm.pub")}"
  }
}
resource "google_compute_instance" "terraform-ubuntu-2" {
  name                      = "gateway"
  machine_type              = "f1-micro"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.gcp_images
    }
  }

  network_interface {
    network = "default"         # default network vpc
    access_config {}
  }
  tags = ["go"]                  # firewall custom name : go = allow all ip
  metadata = {
    ssh_keys       = "komarhidayat0:${file("~/.ssh/gcloud-vm.pub")}"
  }
}

