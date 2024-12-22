variable "asset_storage_bucket" {
  description = "Name of the S3 bucket for storing images"
  type        = string
}

variable "lambda_code_bucket" {
  description = "Name of the S3 bucket containing the Lambda function code"
  type        = string
}

variable "metadata_table_name" {
  description = "Name of the DynamoDB table for storing metadata"
  type        = string
} 
