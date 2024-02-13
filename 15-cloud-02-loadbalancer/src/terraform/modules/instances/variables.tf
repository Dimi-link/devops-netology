variable lamp {
  type        = map
  description = "LAMP Instance Configuration"
}

variable balancer {
  type        = string
  description = "Network load balancer"
}

variable service_account_id {
  type        = string
  description = "Service Account For Instance Group Management"
}

variable user_data {
  type        = string
  description = "cloud-init user-data file path"
}