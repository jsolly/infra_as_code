module "storage" {
  source = "./storage"

  storage_bucket_name = var.storage_bucket_name
}

module "metadata" {
  source = "./metadata"

  metadata_table_name = var.metadata_table_name
}

module "nasa_photo_fetcher" {
  source = "./lambda"

  function_name = "nasa-photo-fetcher"
  handler       = "main.handler"
  runtime       = "python3.9"
  timeout       = 30
  memory_size   = 128

  environment_variables = {
    NASA_API_KEY        = var.nasa_api_key
    STORAGE_BUCKET_NAME = var.storage_bucket_name
    METADATA_TABLE_NAME = var.metadata_table_name
  }

  # Add additional IAM permissions for S3 and DynamoDB
  additional_policies = [
    {
      name = "S3Access"
      statements = [{
        effect = "Allow"
        actions = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        resources = ["${aws_s3_bucket.storage_bucket.arn}/*"]
      }]
    },
    {
      name = "DynamoDBAccess"
      statements = [{
        effect = "Allow"
        actions = [
          "dynamodb:PutItem",
          "dynamodb:GetItem"
        ]
        resources = [aws_dynamodb_table.metadata_table.arn]
      }]
    }
  ]
}
