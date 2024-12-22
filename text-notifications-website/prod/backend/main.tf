module "storage" {
  source               = "./storage"
  asset_storage_bucket = var.asset_storage_bucket
  lambda_code_bucket   = var.lambda_code_bucket
  metadata_table_name  = var.metadata_table_name
}

module "metadata" {
  source              = "./metadata"
  metadata_table_name = var.metadata_table_name
}

module "functions" {
  source                         = "./functions"
  photo_fetcher_name             = var.photo_fetcher_name
  lambda_code_bucket             = var.lambda_code_bucket
  lambda_code_key                = var.lambda_code_key
  nasa_api_key                   = var.nasa_api_key
  asset_storage_bucket_name      = module.storage.asset_storage_bucket_name
  asset_storage_bucket_arn       = module.storage.asset_storage_bucket_arn
  lambda_code_storage_bucket_arn = module.storage.lambda_code_storage_bucket_arn
  metadata_table_name            = module.metadata.metadata_table_name
  metadata_table_arn             = module.metadata.metadata_table_arn
  function_handler               = var.function_handler
  runtime                        = var.runtime
  function_timeout               = var.function_timeout
  function_memory_size           = var.function_memory_size
}
