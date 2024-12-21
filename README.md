# Static Website Infrastructure as Code

This repository contains Terraform configurations for deploying static websites with serverless backends. It currently supports two websites:
- Text Notifications Website (textnotifications.app)
- Personal Website (jsolly.com)

## Infrastructure Patterns

### Frontend Options

#### AWS-Only Infrastructure (`modules/frontend/aws_only`)
Used by jsolly.com, this pattern uses:
- **Content Storage**: Amazon S3 with private access
- **Content Delivery**: Amazon CloudFront with Origin Access Control
- **DNS Management**: Amazon Route53
- **SSL/TLS**: AWS Certificate Manager

#### AWS + Cloudflare Infrastructure (`modules/frontend/aws_plus_cloudflare`)
Used by textnotifications.app, this pattern uses:
- **Content Storage**: Amazon S3 with website hosting enabled
- **Content Delivery**: Cloudflare CDN
- **DNS Management**: Cloudflare DNS
- **SSL/TLS**: Cloudflare SSL

### Backend Infrastructure (`modules/backend`)
The backend infrastructure includes:
- **Asset Storage**: S3 buckets with lifecycle policies
- **Metadata**: DynamoDB tables with TTL support
- **Compute**: Lambda functions with S3-based deployment
- **Scheduling**: EventBridge for scheduled tasks

## Project Structure
```
.
├── modules/
│   ├── backend/
│   │   ├── metadata/      # DynamoDB table configurations
│   │   └── storage/       # S3 bucket configurations
│   └── frontend/
│       ├── aws_only/      # CloudFront + Route53 pattern
│       └── aws_plus_cloudflare/  # S3 + Cloudflare pattern
├── text-notifications-website/
│   └── prod/
│       ├── backend/       # Lambda + DynamoDB + S3
│       └── frontend/      # S3 + Cloudflare
└── jsolly-website/
    └── prod/             # CloudFront + S3 + Route53
```

## Prerequisites

- AWS Account with admin access
- Terraform ~> 5.0
- For textnotifications.app:
  - Cloudflare Account
  - Cloudflare API Token
  - NASA API Key
- For jsolly.com:
  - Route53 Hosted Zone
  - ACM Certificate

## Configuration

1. Create a `terraform.tfvars` file in your project's environment directory:

For AWS + Cloudflare pattern:
```hcl
# Global configuration
aws_region = "us-east-1"

# Frontend configuration
domain_name                      = "example.com"
website_bucket_name              = "example.com"
google_search_console_txt_record = "google-site-verification=<verification_code>"
cloudflare_api_token            = "<cloudflare_api_token>"
cloudflare_zone_id              = "<cloudflare_zone_id>"

# Backend configuration (if needed)
asset_storage_bucket = "example-prod-storage"
metadata_table_name  = "example-prod-metadata"
lambda_code_bucket   = "example-prod-lambda-code"
lambda_code_key      = "functions/your-function/deployment.zip"
```

For AWS-only pattern:
```hcl
certificate_arn     = "arn:aws:acm:<region>:<account_id>:certificate/<certificate_id>"
domain_name         = "example.com"
website_bucket_name = "example-website"
```

2. Initialize and apply Terraform:
```bash
terraform init
terraform plan
terraform apply
```

## License

MIT License - See [LICENSE](LICENSE) for details.