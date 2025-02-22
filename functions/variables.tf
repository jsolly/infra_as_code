variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
  default     = "prod"
}

variable "function_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "function_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "additional_policy_arns" {
  description = "List of additional IAM policy ARNs to attach to the Lambda role"
  type        = list(string)
  default     = []
}

variable "s3_access_arns" {
  description = "List of S3 bucket ARNs the Lambda needs read access to"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "image_uri" {
  description = "The URI of the container image in ECR"
  type        = string
}

variable "ecr_repository_arn" {
  description = "The ARN of the ECR repository containing the function image"
  type        = string
}
