variable "website_bucket_name" {
  description = "Name of the S3 bucket for the website"
  type        = string
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
