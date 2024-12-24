variable "website_bucket_name" {
  description = "Name of the S3 bucket for the website"
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution that needs access to the bucket"
  type        = string
  default     = null
}

