output "bucket_policy" {
  description = "The generated bucket policy (either CloudFront or Cloudflare)"
  value       = local.policy
}