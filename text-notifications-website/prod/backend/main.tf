module "storage" {
  source = "../../../modules/backend/storage"

  storage_bucket_name = var.storage_bucket_name
}

module "metadata" {
  source = "../../../modules/backend/metadata"

  metadata_table_name = var.metadata_table_name
}

module "photo_fetcher" {
  source = "../../../modules/backend/functions/lambda"

  function_name = var.photo_fetcher_name
  handler       = var.function_handler
  runtime       = var.runtime
  timeout       = var.function_timeout
  memory_size   = var.function_memory_size

  environment_variables = {
    API_KEY             = var.api_key
    STORAGE_BUCKET_NAME = module.storage.bucket_name
    METADATA_TABLE_NAME = var.metadata_table_name
  }

  iam_policies = [
    {
      name = "s3-access"
      statements = [{
        effect = "Allow"
        actions = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        resources = ["${module.storage.bucket_arn}/*"]
      }]
    },
    {
      name = "dynamodb-access"
      statements = [{
        effect = "Allow"
        actions = [
          "dynamodb:PutItem",
          "dynamodb:GetItem"
        ]
        resources = [module.metadata.table_arn]
      }]
    }
  ]
}
