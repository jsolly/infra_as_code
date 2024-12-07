resource "aws_s3_bucket" "website_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "bucket_policy" {
  source = "./bucket-policies"
  
  bucket_name                 = aws_s3_bucket.website_bucket.id
  policy_type                 = var.bucket_policy_type
  cloudfront_distribution_arn = try(var.cloudfront_distribution_arn, null)
}

resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = module.bucket_policy.bucket_policy
}
