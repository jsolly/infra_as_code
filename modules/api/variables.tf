variable "storage_bucket_name" {
  description = "Name of the S3 bucket for storing images"
  type        = string
}

variable "metadata_table_name" {
  description = "Name of the DynamoDB table for storing metadata"
  type        = string
} 