resource "yandex_vpc_network" "k8snet" {
  name = "k8snet"
}

resource "yandex_vpc_subnet" "k8ssubnet" {
  name           = "k8ssubnet"
  network_id     = resource.yandex_vpc_network.k8snet.id
  v4_cidr_blocks = ["192.168.56.0/24"]
  zone           = "ru-central1-a"
}

resource "yandex_compute_instance" "k8s-node" {
  name        = "microk8s"
  hostname    = "microk8s.local"

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
    subnet_id = yandex_vpc_subnet.k8ssubnet.id
    nat       = true
    ipv6      = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
