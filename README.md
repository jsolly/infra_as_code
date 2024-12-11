# Static Website Infrastructure as Code

This repository contains Terraform configurations for deploying static websites using two different infrastructure patterns:

## Deployment Patterns

### AWS-Only Infrastructure (`modules/aws_only`)
Uses AWS services exclusively for a complete website hosting solution:
- **Content Storage**: Amazon S3
- **Content Delivery**: Amazon CloudFront CDN
- **DNS Management**: Amazon Route53
- **SSL/TLS**: AWS Certificate Manager

This pattern is ideal for users who want to keep all their infrastructure within AWS and benefit from tight integration between AWS services.

### AWS + Cloudflare Infrastructure (`modules/aws_plus_cloudflare`)
Uses AWS for storage while leveraging Cloudflare's CDN and DNS services:
- **Content Storage**: Amazon S3 with website hosting enabled
- **Content Delivery**: Cloudflare CDN
- **DNS Management**: Cloudflare DNS
- **SSL/TLS**: Cloudflare SSL

This pattern is suitable for users who prefer Cloudflare's CDN features, DDoS protection, and DNS management capabilities.

## Adding a New Website

1. Choose your infrastructure pattern based on your needs:
   - AWS-only: Full AWS stack with CloudFront and Route53
   - AWS+Cloudflare: S3 storage with Cloudflare CDN and DNS
2. Create a new directory for your site
3. Create environment sub-directories (e.g., prod, dev)
4. Configure the required files:
   - `main.tf` - Module configurations
   - `variables.tf` - Variable definitions
   - `terraform.tfvars` - Variable values

## Prerequisites

- AWS Account
- Terraform ~> 5.0
- Cloudflare Account (only if using AWS+Cloudflare pattern)

## Usage

1. Configure your AWS credentials
2. Navigate to your website's environment directory:
   ```bash
   cd your-website/prod
   ```

3. Update the variables in your environment's tfvars file:

   For AWS-only pattern:
   - `certificate_arn` - ACM certificate ARN
   - `domain_name` - Your domain name
   - `bucket_name` - S3 bucket name
   - `aws_account_id` - AWS account ID

   For AWS+Cloudflare pattern:
   - `cloudflare_api_token` - Cloudflare API token
   - `cloudflare_zone_id` - Cloudflare zone ID
   - `domain_name` - Your domain name
   - `bucket_name` - S3 bucket name
   - `google_search_console_txt_record` (optional) - For Google Search Console verification

4. Initialize and apply Terraform:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## License

MIT License - See [LICENSE](LICENSE) for details.