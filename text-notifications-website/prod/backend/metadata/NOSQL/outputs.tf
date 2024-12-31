output "table_arn" {
  description = "ARN of the metadata DynamoDB table"
  value       = aws_dynamodb_table.metadata_table.arn
}

output "table_name" {
  description = "Name of the metadata DynamoDB table"
  value       = aws_dynamodb_table.metadata_table.name
} 
