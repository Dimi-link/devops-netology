output "private_ip_address_terra-node" {
  value = yandex_compute_instance.terra-node.network_interface.0.nat_ip_address
}

output "subnet_ip_address_terra-node" {
  value = yandex_compute_instance.terra-node.network_interface.0.ip_address
}