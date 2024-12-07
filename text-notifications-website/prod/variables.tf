variable "domain_name" {
  description = "Primary domain name (e.g., example.com)"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket to create"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID for the General Account"
  type        = string
}

variable "google_search_console_txt_record" {
  description = "The Google Search Console TXT record"
  type        = string
}

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token"
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "The zone ID for the Cloudflare domain"
  type        = string
}
