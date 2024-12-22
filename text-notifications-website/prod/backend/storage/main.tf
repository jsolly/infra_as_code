module "asset_storage" {
  source         = "../../../../modules/backend/storage"
  storage_bucket = var.asset_storage_bucket
}

module "lambda_code_storage" {
  source         = "../../../../modules/backend/storage"
  storage_bucket = var.lambda_code_bucket
}
