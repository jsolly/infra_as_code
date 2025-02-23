locals {
  role_name      = "${var.function_name}-${var.environment}-role"
  s3_policy_name = "${var.function_name}-${var.environment}-s3-access"
  default_tags = {
    Name        = var.function_name
    Environment = var.environment
  }
  merged_tags = merge(local.default_tags, var.tags)
}

resource "aws_lambda_function" "function" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_role.arn
  timeout       = var.function_timeout
  memory_size   = var.function_memory_size

  package_type  = "Image"
  image_uri     = var.image_uri
  architectures = ["arm64"]

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

resource "aws_iam_role_policy" "ecr_access" {
  name = "${var.function_name}-${var.environment}-ecr-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = [var.ecr_repository_arn]
      }
    ]
  })
}

resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "${var.function_name}-${var.environment}-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = [
      "https://${var.domain_name}",
      "https://www.${var.domain_name}"
    ]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = [
      "content-type",
      "x-amz-date",
      "authorization",
      "x-api-key",
      "x-amz-security-token",
      "x-amz-user-agent",
      "origin",
      "hx-current-url",
      "hx-request"
    ]
    expose_headers = [
      "content-type",
      "content-length",
      "access-control-allow-origin",
      "access-control-allow-methods",
      "access-control-allow-headers"
    ]
    max_age = 300
  }

  tags = local.merged_tags
}

resource "aws_apigatewayv2_stage" "lambda_stage" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = "$default"
  auto_deploy = true

  tags = local.merged_tags
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id = aws_apigatewayv2_api.lambda_api.id

  integration_uri    = aws_lambda_function.function.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "ANY ${var.api_path}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/$default/*${var.api_path}"
}
