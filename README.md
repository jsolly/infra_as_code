# Static Website Infrastructure as Code

This repository contains Terraform configurations for deploying static websites with serverless backends. It currently supports two websites:
- Text Notifications Website (textnotifications.app)
- Personal Website (jsolly.com)

## Infrastructure Patterns

### Frontend Options

#### AWS-Only Infrastructure (`modules/static_website/aws_only`)
Used by jsolly.com, this pattern uses:
- **Content Storage**: Amazon S3 with private access and CloudFront OAC
- **Content Delivery**: Amazon CloudFront with custom functions for directory indexing
- **DNS Management**: Amazon Route53 (A and AAAA records)
- **SSL/TLS**: AWS Certificate Manager

#### AWS + Cloudflare Infrastructure (`modules/static_website/aws_plus_cloudflare`)
Used by textnotifications.app, this pattern uses:
- **Content Storage**: Amazon S3 with website hosting enabled
- **Content Delivery**: Cloudflare CDN with IP-restricted S3 access
- **DNS Management**: Cloudflare DNS (CNAME records)
- **SSL/TLS**: Cloudflare SSL

### Backend Infrastructure
The backend infrastructure (implemented in text-notifications-website/prod/backend) includes:

#### Storage and Metadata
- **Metadata**: DynamoDB tables with TTL support and date-based indexing
- **Compute**: Lambda functions with S3-based deployment and IAM roles
- **Scheduling**: EventBridge for daily scheduled tasks

## Project Structure
```
.
├── modules/
│   └── static_website/                  # Shared code for deployment of static websites
│       ├── aws_only/                    # CloudFront + Route53 + S3 with OAC
│       └── aws_plus_cloudflare/         # S3 + Cloudflare with IP restrictions
├── text-notifications-website/
│   └── prod/
│       └── backend/       
│           └── functions/               # NASA photo fetcher + sender Lambdas
│           └── metadata/                # DynamoDB table configurations
│           └── storage/                 # S3 bucket configurations
└── jsolly-website/
    └── prod/                            # CloudFront + S3 + Route53 configuration
```

## Prerequisites

- AWS Account with admin access
- Terraform ~> 5.0
- For textnotifications.app:
  - Cloudflare Account
  - Cloudflare API Token
  - NASA API Key
  - Twilio Account:
    - Account SID
    - Auth Token
    - Sender Phone Number
    - Target Phone Number
- For jsolly.com:
  - Route53 Hosted Zone
  - ACM Certificate

## Configuration

1. Create a directory for your website (e.g., `text-notifications-website` or `jsolly-website`)
2. Create a `terraform.tfvars` file in your project's environment directory using the provided sample:
   - For text-notifications-website: See `text-notifications-website/prod/sample.terraform.tfvars`
   - For jsolly-website: See `jsolly-website/prod/sample.terraform.tfvars`
3. Initialize and apply Terraform:
```bash
terraform init
terraform plan
terraform apply
```

## License

MIT License - See [LICENSE](LICENSE) for details.