output "distribution_arn" {
  value       = aws_cloudfront_distribution.distribution.arn
  description = "The ARN of the CloudFront distribution"
}

output "domain_name" {
  value = aws_cloudfront_distribution.distribution.domain_name
}

output "hosted_zone_id" {
  value = aws_cloudfront_distribution.distribution.hosted_zone_id
}

