variable hosting_bucket {
  type        = string
  default     = "1.dimi.link"
  description = "bucket name for static website"
}

variable picture_path {
  type        = string
  default     = "pictures/index.png"
  description = "Picture to upload on hosting"
}

variable lamp {
  type        = map
  default     = {
    "image_id" = "fd827b91d99psvq5fjit"
    "cpu" = 2
    "memory" = 2
  }
  description = "LAMP Instance Configuration"
}

variable service_account_id {
  type        = string
  default     = "ajefun8r3vbsid8ng9vt"
  description = "Service Account"
}

variable user_data {
  type        = string
  default     = "user_data.yml"
  description = "Cloud-init user-data file path"
}

variable balancer {
  type        = string
  default     = "nlb"
  description = "Network load Balancer"
}
