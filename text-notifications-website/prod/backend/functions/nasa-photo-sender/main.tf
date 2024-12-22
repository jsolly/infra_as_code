resource "aws_iam_role" "lambda_role" {
  name = "${var.photo_sender_name}-role"

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
  name = "${var.photo_sender_name}-s3-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
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
  name = "${var.photo_sender_name}-dynamodb-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
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

data "aws_s3_object" "lambda_code" {
  bucket = var.lambda_code_bucket
  key    = var.lambda_code_key
}

resource "aws_lambda_function" "nasa_photo_sender" {
  s3_bucket        = var.lambda_code_bucket
  s3_key           = var.lambda_code_key
  source_code_hash = data.aws_s3_object.lambda_code.etag
  function_name    = var.photo_sender_name
  role             = aws_iam_role.lambda_role.arn
  handler          = var.function_handler
  runtime          = var.runtime
  timeout          = var.function_timeout
  memory_size      = var.function_memory_size

  environment {
    variables = {
      TWILIO_ACCOUNT_SID  = var.twilio_account_sid
      TWILIO_AUTH_TOKEN   = var.twilio_auth_token
      TWILIO_PHONE_NUMBER = var.twilio_phone_number
      TARGET_PHONE_NUMBER = var.target_phone_number
      METADATA_TABLE_NAME = var.metadata_table_name
      STORAGE_BUCKET_NAME = var.asset_storage_bucket_name
    }
  }
}

resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "${var.photo_sender_name}-daily-trigger"
  description         = "Triggers the NASA photo sender Lambda function daily at 2 AM"
  schedule_expression = "cron(0 2 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = "TriggerNASAPhotoSender"
  arn       = aws_lambda_function.nasa_photo_sender.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.nasa_photo_sender.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}
