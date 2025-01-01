module "nasa_photo_fetcher" {
  source = "./nasa-apod/photo-fetcher"

  website_bucket_name            = var.website_bucket_name
  nasa_api_key                   = var.nasa_api_key
  lambda_code_storage_bucket_arn = var.lambda_code_storage_bucket_arn
  metadata_table_arn             = var.metadata_table_arn
}

module "nasa_photo_sender" {
  source = "./nasa-apod/photo-sender"

  website_bucket_name            = var.website_bucket_name
  twilio_account_sid             = var.twilio_account_sid
  twilio_auth_token              = var.twilio_auth_token
  twilio_sender_phone_number     = var.twilio_sender_phone_number
  twilio_target_phone_number     = var.twilio_target_phone_number
  lambda_code_storage_bucket_arn = var.lambda_code_storage_bucket_arn
  metadata_table_arn             = var.metadata_table_arn
  nasa_api_key                   = var.nasa_api_key
}

# module "weather_fetcher" {
#   source = "./weather/weather-fetcher"

#   website_bucket_name            = var.website_bucket_name
#   lambda_code_storage_bucket_arn = var.lambda_code_storage_bucket_arn
#   subnet_ids                     = var.private_subnet_ids
#   lambda_security_group_id       = var.lambda_security_group_id
# }
