# Reference Cloudflare IPs so we don't have to hardcode them
data "http" "cloudflare_ips" {
  url = "https://api.cloudflare.com/client/v4/ips"
}

locals {
  cloudflare_ips = jsondecode(data.http.cloudflare_ips.response_body)
}

# Create a bucket for www.domain.com
resource "aws_s3_bucket" "www_bucket" {
  bucket        = "www.${var.bucket_name}"
  force_destroy = true
}


resource "aws_s3_bucket_website_configuration" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id

  index_document {
    suffix = var.website_config.index_document
  }

  error_document {
    key = var.website_config.error_document
  }
}

resource "aws_s3_bucket_public_access_block" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "www_bucket_policy" {
  bucket = aws_s3_bucket.www_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "PublicReadGetObject",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${aws_s3_bucket.www_bucket.id}/*",
        "Condition" : {
          "IpAddress" : {
            "aws:SourceIp" : concat(local.cloudflare_ips.result.ipv4_cidrs, local.cloudflare_ips.result.ipv6_cidrs)
          }
        }
      }
    ]
  })
}


# Create a bucket for domain.com to redirect to www.domain.com
resource "aws_s3_bucket" "website_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "website_bucket" {
  bucket = var.bucket_name

  redirect_all_requests_to {
    host_name = "www.${var.bucket_name}"
    protocol  = "https"
  }
}
