resource "yandex_compute_instance_group" "lamp_group" {
  name               = "lamp-vm"
  service_account_id = var.service_account_id
  deletion_protection = false
  instance_template {
    platform_id = "standard-v2"
    resources {
      cores  = var.lamp.cpu
      memory = var.lamp.memory
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = var.lamp.image_id
      }
    }
    network_interface {
      network_id = "enpg6alfuhprvbup2ls4"
	  subnet_ids = ["e9bi3rm6ek5rgd3mb5qn"]
    }

    metadata = {
      user-data = file(var.user_data)
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 2
    max_creating    = 2
    max_expansion   = 2
    max_deleting    = 2
  }

  dynamic "load_balancer" {
    for_each = var.balancer == "nlb" ? toset([1]) : toset([]) 
    content {
      target_group_name = "lamp-balancer"
    }
  }
}