variable "certificate_arn" {
  description = "ARN of the manually created ACM certificate"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name (e.g., example.com)"
  type        = string
}

variable "website_bucket_name" {
  description = "Name of the S3 bucket to create"
  type        = string
}