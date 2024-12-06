variable "certificate_arn" {
  description = "ARN of the manually created ACM certificate"
  type        = string
}

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

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token"
  sensitive   = true
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare Zone ID for the domain"
}
