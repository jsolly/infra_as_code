resource "aws_s3_bucket" "website_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "website" {
  count  = var.enable_website_hosting ? 1 : 0
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = var.website_config.index_document
  }

  error_document {
    key = var.website_config.error_document
  }
}

resource "aws_s3_bucket_public_access_block" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = !var.enable_website_hosting
  block_public_policy     = !var.enable_website_hosting
  ignore_public_acls      = !var.enable_website_hosting
  restrict_public_buckets = !var.enable_website_hosting
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
