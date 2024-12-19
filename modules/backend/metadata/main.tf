resource "aws_dynamodb_table" "metadata_table" {
  name         = var.metadata_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "date"

  # Primary key - must be in ISO 8601 format (YYYY-MM-DD)
  attribute {
    name = "date"
    type = "S" # String type since dates in DynamoDB are stored as strings
  }

  ttl {
    attribute_name = "expiration_time"
    enabled        = true
  }

  lifecycle {
    ignore_changes = [ttl]
  }

  tags = {
    ExpirationDays = var.expiration_days
  }
}
