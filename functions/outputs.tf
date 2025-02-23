output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.function.arn
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.function.function_name
}

output "role_arn" {
  description = "The ARN of the IAM role"
  value       = aws_iam_role.lambda_role.arn
}

output "api_endpoint" {
  description = "The HTTP API Gateway endpoint URL"
  value       = "${aws_apigatewayv2_api.lambda_api.api_endpoint}${var.api_path}"
}


output "ecr_repository_arn" {
  description = "The ARN of the ECR repository"
  value       = aws_ecr_repository.function.arn
}
