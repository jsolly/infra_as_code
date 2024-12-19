variable "function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "handler" {
  type        = string
  description = "Handler for the Lambda function"
}

variable "runtime" {
  type        = string
  description = "Runtime for the Lambda function"
}

variable "timeout" {
  type        = number
  description = "Timeout in seconds"
  default     = 30
}

variable "memory_size" {
  type        = number
  description = "Memory size in MB"
  default     = 128
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables for the Lambda function"
  default     = {}
}

variable "iam_policies" {
  type = list(object({
    name = string
    statements = list(object({
      effect    = string
      actions   = list(string)
      resources = list(string)
    }))
  }))
  description = "IAM policies to attach to the Lambda role"
  default     = []
} 
