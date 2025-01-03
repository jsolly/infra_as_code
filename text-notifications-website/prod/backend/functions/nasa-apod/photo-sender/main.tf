# These locals follow the naming convention of the website bucket name used in the other modules
locals {
  role_name          = "${var.website_bucket_name}-${var.environment}-nasa-photo-sender-role"
  s3_policy_name     = "${var.website_bucket_name}-${var.environment}-nasa-photo-sender-s3-access"
  dynamo_policy_name = "${var.website_bucket_name}-${var.environment}-nasa-photo-sender-dynamodb-access"
  photo_sender_name  = "${var.website_bucket_name}-${var.environment}-nasa-photo-sender"
  lambda_code_bucket = "${var.website_bucket_name}-${var.environment}-lambda-code"
  lambda_code_key    = "nasa-photo-sender/deployment.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = local.role_name

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

  tags = {
    Name        = local.role_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "s3_access" {
  name = local.s3_policy_name
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["${var.lambda_code_storage_bucket_arn}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy" "dynamodb_access" {
  name = local.dynamo_policy_name
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
  bucket = local.lambda_code_bucket
  key    = local.lambda_code_key
}

resource "aws_lambda_function" "nasa_photo_sender" {
  s3_bucket        = local.lambda_code_bucket
  s3_key           = local.lambda_code_key
  source_code_hash = data.aws_s3_object.lambda_code.etag
  function_name    = local.photo_sender_name
  role             = aws_iam_role.lambda_role.arn
  handler          = var.function_handler
  runtime          = var.runtime
  timeout          = var.function_timeout
  memory_size      = var.function_memory_size

  environment {
    variables = {
      TWILIO_ACCOUNT_SID         = var.twilio_account_sid
      TWILIO_AUTH_TOKEN          = var.twilio_auth_token
      TWILIO_SENDER_PHONE_NUMBER = var.twilio_sender_phone_number
      TWILIO_TARGET_PHONE_NUMBER = var.twilio_target_phone_number
      NASA_API_KEY               = var.nasa_api_key
    }
  }

  tags = {
    Name        = local.photo_sender_name
    Environment = var.environment
  }
}
