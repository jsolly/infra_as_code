module "storage" {
  source = "./storage"

  storage_bucket_name = var.storage_bucket_name
}

module "metadata" {
  source = "./metadata"

  metadata_table_name = var.metadata_table_name
}
