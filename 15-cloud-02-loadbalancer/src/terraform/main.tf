data "yandex_iam_service_account" "lamp" {
  service_account_id = var.service_account_id
}

module buckets {
  source = "./modules/bucket"
  hosting_bucket = var.hosting_bucket
  picture_path = var.picture_path
}

module instances {
  source = "./modules/instances"
  lamp = var.lamp
  balancer = var.balancer
  service_account_id = data.yandex_iam_service_account.lamp.id
  user_data = var.user_data
}

module nlb {
  count = var.balancer == "nlb" ? 1 : 0
  source = "./modules/nlb"
  target_group_id = module.instances.target_group_id
}
