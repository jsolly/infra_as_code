variable "environment" {
  type        = string
  description = "The environment of the website"
  default     = "prod"
}

variable "website_bucket_name" {
  type        = string
  description = "The name of the website bucket"
}

variable "lambda_code_storage_bucket_arn" {
  type        = string
  description = "The ARN of the lambda code storage bucket"
}

variable "metadata_table_arn" {
  type        = string
  description = "The ARN of the metadata table"
}

variable "function_handler" {
  type        = string
  description = "The handler for the lambda function"
  default     = "index.handler"
}

variable "runtime" {
  type        = string
  description = "The runtime for the lambda function"
  default     = "python3.12"
}

variable "function_timeout" {
  type        = number
  description = "The timeout for the lambda function"
  default     = 30
}

variable "function_memory_size" {
  type        = number
  description = "The memory size for the lambda function"
  default     = 128
}

variable "nasa_api_key" {
  type        = string
  description = "The API key for the NASA API"
}


