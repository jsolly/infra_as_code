output "s3_raw_hash" {
  description = "The raw ETag from S3 object"
  value       = data.aws_s3_object.lambda_code.etag
}

output "lambda_code_bucket" {
  value = var.lambda_code_bucket
}

output "lambda_code_key" {
  value = var.lambda_code_key
}
