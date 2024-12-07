variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "policy_type" {
  description = "Type of bucket policy to use (cloudfront or cloudflare)"
  type        = string
  
  validation {
    condition     = contains(["cloudfront", "cloudflare"], var.policy_type)
    error_message = "policy_type must be either 'cloudfront' or 'cloudflare'"
  }
}

variable "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution that needs access to the bucket"
  type        = string
  default     = null
} 