module "lambda_code_storage" {
  source              = "./storage"
  storage_bucket_name = "${var.website_bucket_name}-${var.environment}-lambda-code"
  environment         = var.environment
}

module "asset_storage" {
  source              = "./storage"
  storage_bucket_name = "${var.website_bucket_name}-${var.environment}-assets"
  environment         = var.environment
}

module "metadata" {
  source              = "./metadata"
  website_bucket_name = var.website_bucket_name
  environment         = var.environment
}

module "functions" {
  source                         = "./functions"
  website_bucket_name            = var.website_bucket_name
  nasa_api_key                   = var.nasa_api_key
  lambda_code_storage_bucket_arn = module.lambda_code_storage.bucket_arn
  asset_storage_bucket_arn       = module.asset_storage.bucket_arn
  metadata_table_arn             = module.metadata.table_arn
  twilio_account_sid             = var.twilio_account_sid
  twilio_auth_token              = var.twilio_auth_token
  twilio_sender_phone_number     = var.twilio_sender_phone_number
  twilio_target_phone_number     = var.twilio_target_phone_number
}
