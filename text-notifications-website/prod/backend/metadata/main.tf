locals {
  metadata_table_name = "${var.website_bucket_name}-${var.environment}-metadata"
}

resource "aws_dynamodb_table" "metadata_table" {
  name         = local.metadata_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"
  range_key    = "SK"

  # Partition key - will contain "APOD" to group all records
  attribute {
    name = "PK"
    type = "S"
  }

  # Sort key - ISO 8601 format (YYYY-MM-DD)
  # Items are automatically sorted by this key within each partition
  attribute {
    name = "SK"
    type = "S"
  }

  # Global Secondary Index for querying by date directly
  global_secondary_index {
    name            = "DateIndex"
    hash_key        = "SK"
    projection_type = "ALL"
    read_capacity   = 0
    write_capacity  = 0
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
