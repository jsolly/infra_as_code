output "bucket_domain_name" {
  value = aws_s3_bucket.website_bucket.bucket_regional_domain_name
}

output "bucket_id" {
  value = aws_s3_bucket.website_bucket.id
}

output "bucket_policy" {
  description = "The bucket policy document"
  value       = aws_s3_bucket_policy.www_bucket_policy
}

output "website_bucket_name" {
  description = "Name of the S3 bucket (same as bucket ID)"
  value       = aws_s3_bucket.website_bucket.bucket
}

output "website_bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.website_bucket.arn
}
