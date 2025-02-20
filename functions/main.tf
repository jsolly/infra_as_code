locals {
  role_name      = "${var.function_name}-${var.environment}-role"
  s3_policy_name = "${var.function_name}-${var.environment}-s3-access"
  default_tags = {
    Name        = var.function_name
    Environment = var.environment
  }
  merged_tags = merge(local.default_tags, var.tags)
}

data "aws_s3_object" "lambda_code" {
  bucket = var.lambda_code_bucket
  key    = var.lambda_code_key
}

resource "aws_lambda_function" "function" {
  s3_bucket        = var.lambda_code_bucket
  s3_key           = var.lambda_code_key
  source_code_hash = data.aws_s3_object.lambda_code.etag
  function_name    = var.function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = var.function_handler
  runtime          = var.runtime
  timeout          = var.function_timeout
  memory_size      = var.function_memory_size

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  tags = local.merged_tags
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

  tags = local.merged_tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "s3_access" {
  count = length(var.s3_access_arns) > 0 ? 1 : 0
  name  = local.s3_policy_name
  role  = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = var.s3_access_arns
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "additional_policies" {
  count      = length(var.additional_policy_arns)
  role       = aws_iam_role.lambda_role.name
  policy_arn = var.additional_policy_arns[count.index]
}
