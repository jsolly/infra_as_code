variable "website_bucket_name" {
  type        = string
  description = "Name of the website bucket"
}

variable "nasa_api_key" {
  type        = string
  description = "API key for the NASA photo service"
  sensitive   = true
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
