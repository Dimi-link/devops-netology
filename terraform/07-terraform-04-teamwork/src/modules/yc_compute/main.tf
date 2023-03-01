data "yandex_compute_image" "this" {
  family    = var.image_family
  folder_id = var.folder_id
}

resource "yandex_vpc_network" "terranet" {
  name = "terranet"
}

resource "yandex_vpc_subnet" "this" {
  name       = var.subnet
  network_id = yandex_vpc_network.terranet.id
  v4_cidr_blocks = ["192.168.56.0/24"]
}

resource "yandex_compute_instance" "this" {
  count = var.instance_count

  name        = var.name
  platform_id = var.platform_id
  zone        = var.zones[0]

  hostname = var.hostname

  resources {
    cores         = var.cores
    memory        = var.memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.this.id
      type     = "network-nvme"
      size     = var.size
    }
  }


  network_interface {
    subnet_id          = yandex_vpc_subnet.this.id
    nat                = var.is_nat
  }


  metadata = {
    ssh-keys = "${var.ssh_username}:${file("${var.ssh_pubkey}")}"
  }

  allow_stopping_for_update = true

  depends_on = [
    yandex_vpc_subnet.this
  ]
}