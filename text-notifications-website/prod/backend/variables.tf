variable "asset_storage_bucket" {
  description = "Name of the S3 bucket for storing images"
  type        = string
}

variable "metadata_table_name" {
  description = "Name of the DynamoDB table for storing metadata"
  type        = string
}

variable "photo_fetcher_name" {
  type        = string
  description = "Name of the photo fetcher Lambda function"
  default     = "photo-fetcher"
}

variable "lambda_code_bucket" {
  description = "Name of the S3 bucket containing the Lambda function code"
  type        = string
}

variable "lambda_code_key" {
  description = "Path to the Lambda zip file"
  type        = string
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
