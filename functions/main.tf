locals {
  role_name      = "${var.function_name}-role"
  s3_policy_name = "${var.function_name}-s3"
  default_tags = {
    Name        = var.function_name
    Environment = var.environment
  }
  merged_tags = merge(local.default_tags, var.tags)
}

# Create the Lambda function with container image configuration
resource "aws_lambda_function" "function" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_role.arn
  timeout       = var.function_timeout
  memory_size   = var.function_memory_size

  package_type  = "Image"
  image_uri     = var.image_uri
  architectures = ["arm64"]

  environment {
    variables = var.environment_variables
  }

  tags = local.merged_tags
}

# Create IAM role for Lambda execution
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

# Attach basic Lambda execution policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create S3 access policy for Lambda if S3 access is required
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

# Create ECR access policy for Lambda to pull container images
resource "aws_iam_role_policy" "ecr_access" {
  name = "${var.function_name}-ecr"
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

# Create HTTP API Gateway with CORS configuration
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "${var.function_name}-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = [
      "https://${var.domain_name}",
      "https://www.${var.domain_name}",
    ]
    allow_methods = [var.http_method, "OPTIONS"]
    allow_headers = [
      # Standard HTTP headers
      "accept",
      "accept-encoding",
      "accept-language",
      "content-type",
      "content-length",

      # Cache control
      "cache-control",
      "pragma",

      # Security and authentication
      "authorization",
      "x-api-key",
      "origin",
      "cf-turnstile-response",

      # AWS specific headers
      "x-amz-date",
      "x-amz-security-token",
      "x-amz-user-agent",

      # HTMX specific headers
      "hx-current-url",
      "hx-request",
      "hx-trigger",
      "hx-target",
      "hx-swap",

      # Browser security and context headers
      "referer",
      "sec-fetch-dest",
      "sec-fetch-mode",
      "sec-fetch-site",
      "sec-ch-ua",
      "sec-ch-ua-mobile",
      "sec-ch-ua-platform",
      "sec-gpc"
    ]
    expose_headers = [
      # Standard HTTP headers
      "content-type",
      "content-length",


      # CORS response headers
      "access-control-allow-origin",
      "access-control-allow-methods",
      "access-control-allow-headers",
      "access-control-expose-headers",
      "access-control-max-age"
    ]
    max_age = 7200
  }

  tags = local.merged_tags
}

# Create default stage for API Gateway with auto-deploy enabled
resource "aws_apigatewayv2_stage" "lambda_stage" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = "$default"
  auto_deploy = true

  tags = local.merged_tags
}

# Configure integration between API Gateway and Lambda function (The Gateway invokes the Lambda function via POST)
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id = aws_apigatewayv2_api.lambda_api.id

  integration_uri    = aws_lambda_function.function.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

# Define API route for the Lambda function
resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "${var.http_method} ${var.api_path}" # e.g. POST /signup
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Define OPTIONS route for preflight requests
# This will be automatically handled by API Gateway's CORS configuration
resource "aws_apigatewayv2_route" "options_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "OPTIONS ${var.api_path}"
}

# Grant API Gateway permission to invoke the Lambda function
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/$default/*${var.api_path}"
}

# Create EventBridge rule for scheduled invocation if schedule expression is provided
resource "aws_cloudwatch_event_rule" "schedule" {
  count               = var.schedule_expression != "" ? 1 : 0
  name                = "${var.function_name}-schedule"
  description         = "Schedule for invoking ${var.function_name} Lambda function"
  schedule_expression = var.schedule_expression
  tags                = local.merged_tags
}

# Create IAM role for EventBridge to invoke Lambda
resource "aws_iam_role" "eventbridge_role" {
  count = var.schedule_expression != "" ? 1 : 0
  name  = "${var.function_name}-eb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
    }]
  })

  tags = local.merged_tags
}

# Attach policy to allow EventBridge to invoke Lambda
resource "aws_iam_role_policy" "eventbridge_invoke_lambda" {
  count = var.schedule_expression != "" ? 1 : 0
  name  = "${var.function_name}-invoke"
  role  = aws_iam_role.eventbridge_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction"]
        Resource = [aws_lambda_function.function.arn]
      }
    ]
  })
}

# Set Lambda function as target for the EventBridge rule
resource "aws_cloudwatch_event_target" "lambda_target" {
  count     = var.schedule_expression != "" ? 1 : 0
  rule      = aws_cloudwatch_event_rule.schedule[0].name
  target_id = "${var.function_name}-target"
  arn       = aws_lambda_function.function.arn
  role_arn  = aws_iam_role.eventbridge_role[0].arn
}

# Grant EventBridge permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_eventbridge" {
  count         = var.schedule_expression != "" ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule[0].arn
}
