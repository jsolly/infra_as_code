# TODO: Implement weather fetcher

locals {
  role_name            = "${var.website_bucket_name}-${var.environment}-weather-fetcher-role"
  weather_fetcher_name = "${var.website_bucket_name}-${var.environment}-weather-fetcher"
  lambda_code_bucket   = "${var.website_bucket_name}-${var.environment}-lambda-code"
  lambda_code_key      = "weather-fetcher/deployment.zip"
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
}

# Allow Lambda to access VPC
resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Allow Lambda to read SSM parameters
resource "aws_iam_role_policy" "ssm_access" {
  name = "${local.role_name}-ssm-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/weather-notifications/${var.environment}/db/*"
        ]
      }
    ]
  })
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_s3_object" "lambda_code" {
  bucket = local.lambda_code_bucket
  key    = local.lambda_code_key
}

resource "aws_lambda_function" "weather_fetcher" {
  s3_bucket        = local.lambda_code_bucket
  s3_key           = local.lambda_code_key
  source_code_hash = data.aws_s3_object.lambda_code.etag
  function_name    = local.weather_fetcher_name
  role             = aws_iam_role.lambda_role.arn
  handler          = var.function_handler
  runtime          = var.runtime
  timeout          = var.function_timeout
  memory_size      = var.function_memory_size

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      DB_SECRET_PATH = "/weather-notifications/${var.environment}/db"
      ENVIRONMENT    = var.environment
    }
  }

  tags = {
    Name        = local.weather_fetcher_name
    Environment = var.environment
  }
}
