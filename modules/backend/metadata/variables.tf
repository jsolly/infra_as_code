variable "metadata_table_name" {
  description = "Name of the DynamoDB table for storing metadata"
  type        = string
}

variable "expiration_days" {
  description = "Number of days after which items in the metadata table expire"
  type        = number
  default     = 30
}
