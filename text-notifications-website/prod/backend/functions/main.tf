module "nasa_photo_fetcher" {
  source = "./nasa-photo-fetcher"

  website_bucket_name            = var.website_bucket_name
  nasa_api_key                   = var.nasa_api_key
  asset_storage_bucket_arn       = var.asset_storage_bucket_arn
  lambda_code_storage_bucket_arn = var.lambda_code_storage_bucket_arn
  metadata_table_arn             = var.metadata_table_arn
}

# module "nasa_photo_sender" {
#   source = "./nasa-photo-sender"

#   website_bucket_name            = var.website_bucket_name
#   twilio_account_sid             = var.twilio_account_sid
#   twilio_auth_token              = var.twilio_auth_token
#   twilio_phone_number            = var.twilio_phone_number
#   target_phone_number            = var.target_phone_number
#   asset_storage_bucket_arn       = var.asset_storage_bucket_arn
#   lambda_code_storage_bucket_arn = var.lambda_code_storage_bucket_arn
#   metadata_table_arn             = var.metadata_table_arn
# }
