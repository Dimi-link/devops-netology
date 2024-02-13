terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.104.0"
    }
  }
}

locals {
  folder_id = "b1gn6do9flnmpvijh6jq"
  cloud_id = "b1gedscku2ft2bla1ngv"
}

provider "yandex" {
  folder_id = local.folder_id
  cloud_id = local.cloud_id
  service_account_key_file = "authorized_key.json"
  zone = "ru-central1-a"
}
