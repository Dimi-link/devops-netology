provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id                 = "b1gedscku2ft2bla1ngv"
  folder_id                = "b1gn6do9flnmpvijh6jq"
  zone                     = "ru-central1-a"
}

module "vpc_node01" {
  source  = "./modules/yc_compute"
  name     = "development"
  hostname = "dev"
  cores  = 1
  memory = 2
  size   = "20"
}

module "vpc_node02" {
  source  = "./modules/yc_compute"
  name     = "stage"
  hostname = "stg"
  cores  = 2
  memory = 4
  size   = "20"
}

module "vpc_node03" {
  source  = "./modules/yc_compute"
  name     = "production"
  hostname = "prod"
  cores  = 4
  memory = 4
  size   = "40"
}