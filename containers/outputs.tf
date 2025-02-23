output "repository_arn" {
  description = "The ARN of the repository"
  value       = aws_ecr_repository.function.arn
}
