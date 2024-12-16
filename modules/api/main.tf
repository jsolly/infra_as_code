resource "aws_s3_bucket" "storage_bucket" {
  bucket        = var.storage_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "storage_bucket" {
  bucket = aws_s3_bucket.storage_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "storage_bucket" {
  bucket = aws_s3_bucket.storage_bucket.id

  rule {
    id     = "delete_old_objects"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}

resource "aws_dynamodb_table" "metadata_table" {
  name           = var.metadata_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "date"
  stream_enabled = true

  attribute {
    name = "date"
    type = "S"
  }

  ttl {
    attribute_name = "expiration_time"
    enabled        = true
  }
}
