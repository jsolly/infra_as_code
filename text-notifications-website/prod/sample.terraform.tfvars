# Global configuration
aws_region = "us-east-1"

# Frontend configuration
domain_name                      = "example.com"
website_bucket_name              = "example-website"
google_search_console_txt_record = "\"google-site-verification=<verification_code>\""
cloudflare_api_token             = "<cloudflare_api_token>"
cloudflare_zone_id               = "<cloudflare_zone_id>"

# Backend configuration
asset_storage_bucket = "example-storage"
metadata_table_name  = "example-metadata"
photo_fetcher_name   = "photo-fetcher"
lambda_code_bucket   = "example-lambda-code"
lambda_code_key      = "../functions/nasa-photo-fetcher/deployment.zip"
nasa_api_key         = "example-api-key"
function_handler     = "index.handler"
runtime              = "python3.12"
function_timeout     = 30
function_memory_size = 128
