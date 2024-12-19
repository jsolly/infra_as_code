variable "storage_bucket_name" {
  description = "Name of the S3 bucket for storing images"
  type        = string
}

variable "expiration_days" {
  description = "Number of days after which items in the storage bucket expire"
  type        = number
  default     = 30
}
