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
        Resource = ["${var.asset_storage_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["${var.lambda_code_storage_bucket_arn}/*"]
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
        Resource = [var.metadata_table_arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function and related resources
data "aws_s3_object" "lambda_code" {
  bucket = var.lambda_code_bucket
  key    = var.lambda_code_key
}

resource "aws_lambda_function" "nasa_photo_fetcher" {
  s3_bucket        = var.lambda_code_bucket
  s3_key           = var.lambda_code_key
  source_code_hash = data.aws_s3_object.lambda_code.etag
  function_name    = var.photo_fetcher_name
  role             = aws_iam_role.lambda_role.arn
  handler          = var.function_handler
  runtime          = var.runtime
  timeout          = var.function_timeout
  memory_size      = var.function_memory_size

  environment {
    variables = {
      NASA_API_KEY         = var.nasa_api_key
      ASSET_STORAGE_BUCKET = var.asset_storage_bucket_name
      METADATA_TABLE_NAME  = var.metadata_table_name
    }
  }
}

resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "${var.photo_fetcher_name}-daily-trigger"
  description         = "Triggers the NASA photo fetcher Lambda function daily at 1 AM"
  schedule_expression = "cron(0 1 * * ? *)"
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
