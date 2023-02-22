provider "yandex" {
  cloud_id                 = "b1gedscku2ft2bla1ngv"
  folder_id                = "b1gn6do9flnmpvijh6jq"
  zone                     = "ru-central1-a"
}


resource "yandex_vpc_network" "terranet" {
  name = "terranet"
}

resource "yandex_vpc_subnet" "terrasubnet" {
  name           = "terrasubnet"
  network_id     = resource.yandex_vpc_network.terranet.id
  v4_cidr_blocks = ["192.168.56.0/24"]
  zone           = "ru-central1-a"
}

resource "yandex_compute_instance" "terra-node" {
  name        = "terraform-vm"
  hostname    = "terraform-vm.local"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 100
  }

boot_disk {
    initialize_params {
      image_id = "fd8p48mt3mentd2avl76"
      type        = "network-nvme"
      size        = "20"
    }
}

network_interface {
    subnet_id = yandex_vpc_subnet.terrasubnet.id
    nat       = true
    ipv6      = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}