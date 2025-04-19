locals {
  default_tags = {
    Name        = var.repository_name
    Environment = var.environment
  }
  merged_tags = merge(local.default_tags, var.tags)
}

# Create ECR repository for the Lambda function
resource "aws_ecr_repository" "function" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true

  tags = local.merged_tags
}

# Add lifecycle policy to clean up old images
resource "aws_ecr_lifecycle_policy" "function" {
  repository = aws_ecr_repository.function.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep the last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
