variable "cloudflare_zone_id" {
  description = "The zone ID for the Cloudflare domain"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the website (e.g., example.com)"
  type        = string
}

variable "s3_website_endpoint" {
  description = "The S3 bucket website endpoint"
  type        = string
}

variable "google_search_console_txt_record" {
  description = "TXT record value for Google Search Console verification"
  type        = string
}

variable "cloudflare_api_token" {
  description = "The API token for the Cloudflare account"
  type        = string
}