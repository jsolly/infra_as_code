variable "domain_name" {
  description = "Base domain name for the application (e.g., example.com)"
  type        = string
}

variable "storage_bucket_name" {
  description = "Name of the S3 bucket for storage"
  type        = string
}

variable "metadata_table_name" {
  description = "Name of the DynamoDB table for metadata"
  type        = string
}

variable "website_bucket_name" {
  description = "Name of the S3 bucket to create for the static website"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
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
