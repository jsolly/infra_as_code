resource "aws_lambda_function" "function" {
  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size
  role          = aws_iam_role.function_role.arn

  environment {
    variables = var.environment_variables
  }
}

resource "aws_iam_role" "function_role" {
  name = "${var.function_name}-role"

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

resource "aws_iam_role_policy_attachment" "function_basic" {
  role       = aws_iam_role.function_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "function_policies" {
  for_each = { for policy in var.iam_policies : policy.name => policy }
  name     = "${var.function_name}-${each.value.name}"
  role     = aws_iam_role.function_role.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = each.value.statements
  })
} 
