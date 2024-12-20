module "storage" {
  source              = "../../../modules/backend/storage"
  storage_bucket_name = var.storage_bucket_name
}

module "metadata" {
  source              = "../../../modules/backend/metadata"
  metadata_table_name = var.metadata_table_name
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.photo_fetcher_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "s3_access" {
  name = "${var.photo_fetcher_name}-s3-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = ["${module.storage.bucket_arn}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy" "dynamodb_access" {
  name = "${var.photo_fetcher_name}-dynamodb-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem"
        ]
        Resource = [module.metadata.table_arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "nasa_photo_fetcher" {
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  function_name    = var.photo_fetcher_name
  role             = aws_iam_role.lambda_role.arn
  handler          = var.function_handler
  runtime          = var.runtime
  timeout          = var.function_timeout
  memory_size      = var.function_memory_size

  environment {
    variables = {
      NASA_API_KEY        = var.nasa_api_key
      STORAGE_BUCKET_NAME = module.storage.bucket_name
      METADATA_TABLE_NAME = module.metadata.table_name
    }
  }
}

resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "${var.photo_fetcher_name}-daily-trigger"
  description         = "Triggers the NASA photo fetcher Lambda function daily at 1 AM"
  schedule_expression = "cron(0 1 * * ? *)" # Runs at 1 AM UTC daily
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = "TriggerNASAPhotoFetcher"
  arn       = aws_lambda_function.nasa_photo_fetcher.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.nasa_photo_fetcher.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}

