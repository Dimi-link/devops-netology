resource "yandex_iam_service_account" "sa" {
  folder_id = "b1gn6do9flnmpvijh6jq"
  name      = "sa-bucket"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = "b1gn6do9flnmpvijh6jq"
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "hosting" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = var.hosting_bucket
  acl    = "public-read"

  website {
    index_document = "index.png"
    error_document = "error.html"
  }
}

resource "yandex_storage_object" "picture" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = yandex_storage_bucket.hosting.id
  key    = "index.png"
  source = var.picture_path
}