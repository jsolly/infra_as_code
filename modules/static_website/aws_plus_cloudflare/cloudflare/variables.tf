variable "cloudflare_zone_id" {
  description = "The zone ID for your Cloudflare domain"
  type        = string
}
variable "domain_name" {
  description = "The domain name (e.g., textnotifications.app)"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "aws_region" {
  description = "The AWS region where the S3 bucket is located"
  type        = string
}

variable "google_search_console_txt_record" {
  description = "The TXT record value for Google Search Console verification"
  type        = string
}