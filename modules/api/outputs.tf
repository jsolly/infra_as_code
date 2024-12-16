output "storage_bucket_name" {
  description = "Name of the storage bucket"
  value       = aws_s3_bucket.storage_bucket.id
}

output "storage_bucket_arn" {
  description = "ARN of the storage bucket"
  value       = aws_s3_bucket.storage_bucket.arn
}

output "metadata_table_name" {
  description = "Name of the metadata DynamoDB table"
  value       = aws_dynamodb_table.metadata_table.name
}

output "metadata_table_arn" {
  description = "ARN of the metadata DynamoDB table"
  value       = aws_dynamodb_table.metadata_table.arn
} 