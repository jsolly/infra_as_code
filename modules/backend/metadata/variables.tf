variable "expiration_days" {
  description = "Number of days after which items in the metadata table expire"
  type        = number
  default     = 30
}

variable "website_bucket_name" {
  type        = string
  description = "Base name of the website bucket"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., prod, dev, staging)"
  default     = "prod"
}
