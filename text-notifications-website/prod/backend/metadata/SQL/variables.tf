variable "environment" {
  description = "Environment name (e.g., prod, dev, staging)"
  type        = string
}

variable "website_bucket_name" {
  description = "Name of the website bucket (used to generate database username)"
  type        = string
}
