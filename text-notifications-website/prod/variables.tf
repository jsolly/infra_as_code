## Global variables

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token"
  sensitive   = true
}

## Frontend variables

variable "google_search_console_txt_record" {
  description = "The Google Search Console TXT record"
  type        = string
}

variable "website_bucket_name" {
  description = "Name of the S3 bucket to create for the static website"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "The zone ID for the Cloudflare domain"
  type        = string
}

variable "domain_name" {
  description = "Base domain name for the application (e.g., example.com)"
  type        = string
}

## Backend variables

variable "storage_bucket_name" {
  description = "Name of the S3 bucket for storage"
  type        = string
}

variable "metadata_table_name" {
  description = "Name of the DynamoDB table for metadata"
  type        = string
}


variable "photo_fetcher_name" {
  type        = string
  description = "Name of the photo fetcher Lambda function"
  default     = "photo-fetcher"
}

variable "lambda_zip_path" {
  type        = string
  description = "Path to the Lambda zip file"
}

variable "nasa_api_key" {
  type        = string
  description = "API key for the NASA photo service"
  sensitive   = true
}

variable "function_handler" {
  type        = string
  description = "Handler function for the Lambda"
  default     = "index.handler"
}

variable "runtime" {
  type        = string
  description = "Runtime for the Lambda function"
  default     = "python3.11"
}

variable "function_timeout" {
  type        = number
  description = "Timeout for the Lambda function in seconds"
  default     = 30
}

variable "function_memory_size" {
  type        = number
  description = "Memory size for the Lambda function in MB"
  default     = 128
}
