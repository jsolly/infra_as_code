output "repository_arn" {
  description = "The ARN of the repository"
  value       = aws_ecr_repository.function.arn
}

output "repository_url" {
  description = "The URL of the repository"
  value       = aws_ecr_repository.function.repository_url
}
