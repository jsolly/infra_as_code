module "cloudflare" {
  source                           = "../../../modules/frontend/aws_plus_cloudflare/cloudflare"
  cloudflare_zone_id               = var.cloudflare_zone_id
  domain_name                      = var.domain_name
  website_bucket_name              = var.website_bucket_name
  aws_region                       = var.aws_region
  google_search_console_txt_record = var.google_search_console_txt_record
}

module "s3" {
  source              = "../../../modules/frontend/aws_plus_cloudflare/s3"
  website_bucket_name = var.website_bucket_name
  website_config = {
    index_document = "index.html"
    error_document = "500.html"
  }
}
