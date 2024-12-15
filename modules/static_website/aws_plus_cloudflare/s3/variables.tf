variable "bucket_name" {
  description = "Name of the S3 bucket to create"
  type        = string
}

variable "bucket_policy_type" {
  description = "Type of bucket policy to use (cloudfront or cloudflare)"
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution that needs access to the bucket"
  type        = string
  default     = null
}

variable "enable_website_hosting" {
  description = "Enable S3 static website hosting"
  type        = bool
  default     = false
}

variable "website_config" {
  description = "Configuration for static website hosting"
  type = object({
    index_document = string
    error_document = string
  })
  default = {
    index_document = "index.html"
    error_document = "500.html"
  }
}
