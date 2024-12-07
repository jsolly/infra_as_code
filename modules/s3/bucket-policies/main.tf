# Use dynamic policy based on type
locals {
  policy = var.policy_type == "cloudfront" ? data.aws_iam_policy_document.cloudfront[0].json : data.aws_iam_policy_document.cloudflare[0].json
}

# CloudFront policy
data "aws_iam_policy_document" "cloudfront" {
  count = var.policy_type == "cloudfront" ? 1 : 0

  statement {
    sid = "AllowCloudFrontAccess"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [var.cloudfront_distribution_arn]
    }
  }
}

# Cloudflare policy
data "aws_iam_policy_document" "cloudflare" {
  count = var.policy_type == "cloudflare" ? 1 : 0

  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = [
        "103.21.244.0/22",
        "103.22.200.0/22",
        "103.31.4.0/22",
        "104.16.0.0/13",
        "104.24.0.0/14",
        "108.162.192.0/18",
        "131.0.72.0/22",
        "141.101.64.0/18",
        "162.158.0.0/15",
        "172.64.0.0/13",
        "173.245.48.0/20",
        "188.114.96.0/20",
        "190.93.240.0/20",
        "197.234.240.0/22",
        "198.41.128.0/17"
      ]
    }
  }
}