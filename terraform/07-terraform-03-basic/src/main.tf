provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = "b1gedscku2ft2bla1ngv"
  folder_id = "b1gn6do9flnmpvijh6jq"
  zone      = "ru-central1-a"
}

resource "yandex_compute_instance" "vm-1-count" {
  
  count = local.instance_count[terraform.workspace]
  name = "${terraform.workspace}-count-${count.index}"

  resources {
    cores  = local.vm_cores[terraform.workspace]
    memory = local.vm_memory[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id = "fd8p48mt3mentd2avl76"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "yandex_compute_instance" "vm-1-fe" {
  
  for_each = local.vm_foreach[terraform.workspace]
  name = "${terraform.workspace}-foreach-${each.key}"

  resources {
    cores  = each.value.cores
    memory = each.value.memory
  }

  boot_disk {
    initialize_params {
      image_id = "fd8p48mt3mentd2avl76"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.56.0/24"]
}


locals {
  instance_count = {
    "prod"=2
    "stage"=1
  }
  vm_cores = {
    "prod"=2
    "stage"=1
  }
  vm_memory = {
    "prod"=2
    "stage"=1
  }
  vm_foreach = {
    prod = {
      "3" = { cores = "2", memory = "2" },
      "2" = { cores = "2", memory = "2" }
    }
	stage = {
      "1" = { cores = "1", memory = "1" }
    }
  }
}