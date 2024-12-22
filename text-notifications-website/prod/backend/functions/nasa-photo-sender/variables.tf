variable "photo_sender_name" {
  type        = string
  description = "Name of the photo sender Lambda function"
}

variable "lambda_code_bucket" {
  description = "Name of the S3 bucket containing the Lambda function code"
  type        = string
}

variable "lambda_code_key" {
  description = "Path to the Lambda zip file"
  type        = string
}

variable "asset_storage_bucket_name" {
  type        = string
  description = "Name of the asset storage bucket"
}

variable "metadata_table_name" {
  type        = string
  description = "Name of the metadata DynamoDB table"
}

variable "twilio_account_sid" {
  type        = string
  description = "Twilio Account SID"
  sensitive   = true
}

variable "twilio_auth_token" {
  type        = string
  description = "Twilio Auth Token"
  sensitive   = true
}

variable "twilio_phone_number" {
  type        = string
  description = "Twilio Phone Number"
}

variable "target_phone_number" {
  type        = string
  description = "Target Phone Number to send messages to"
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

variable "asset_storage_bucket_arn" {
  type        = string
  description = "ARN of the asset storage bucket"
}

variable "lambda_code_storage_bucket_arn" {
  type        = string
  description = "ARN of the Lambda code storage bucket"
}

variable "metadata_table_arn" {
  type        = string
  description = "ARN of the metadata DynamoDB table"
} 
