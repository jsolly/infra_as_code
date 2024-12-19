# Static Website Infrastructure as Code

This repository contains Terraform configurations for deploying static websites and their backend services using different infrastructure patterns.

## Frontend Deployment Patterns

### AWS-Only Infrastructure (`modules/frontend/aws_only`)
Uses AWS services exclusively for a complete website hosting solution:
- **Content Storage**: Amazon S3
- **Content Delivery**: Amazon CloudFront CDN
- **DNS Management**: Amazon Route53
- **SSL/TLS**: AWS Certificate Manager

This pattern is ideal for users who want to keep all their infrastructure within AWS and benefit from tight integration between AWS services.

### AWS + Cloudflare Infrastructure (`modules/frontend/aws_plus_cloudflare`)
Uses AWS for storage while leveraging Cloudflare's CDN and DNS services:
- **Content Storage**: Amazon S3 with website hosting enabled
- **Content Delivery**: Cloudflare CDN
- **DNS Management**: Cloudflare DNS
- **SSL/TLS**: Cloudflare SSL

This pattern is suitable for users who prefer Cloudflare's CDN features, DDoS protection, and DNS management capabilities.

## Backend Infrastructure
The backend infrastructure includes:
- **Storage**: S3 buckets for data storage
- **Database**: DynamoDB tables for metadata
- **Compute**: Lambda functions for serverless processing

## Adding a New Website

1. Choose your frontend infrastructure pattern based on your needs:
   - AWS-only: Full AWS stack with CloudFront and Route53
   - AWS+Cloudflare: S3 storage with Cloudflare CDN and DNS

2. Create a new directory for your site with the following structure:
   ```
   your-website/
   ├── prod/
   │   ├── frontend/  # Production frontend infrastructure
   │   └── backend/   # Production backend services
   └── dev/
       ├── frontend/  # Development frontend infrastructure
       └── backend/   # Development backend services
   ```

3. Configure the required files in each directory:
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
   cd your-website/prod/frontend
   ```

3. Update the variables in your environment's tfvars file:

   For frontend (AWS-only pattern):
   - `certificate_arn` - ACM certificate ARN
   - `domain_name` - Your domain name
   - `website_bucket_name` - S3 bucket name for the website

   For frontend (AWS+Cloudflare pattern):
   - `cloudflare_api_token` - Cloudflare API token
   - `cloudflare_zone_id` - Cloudflare zone ID
   - `domain_name` - Your domain name
   - `website_bucket_name` - S3 bucket name for the website
   - `google_search_console_txt_record` (optional) - For Google Search Console verification

   For backend:
   - `storage_bucket_name` - S3 bucket name for data storage
   - `metadata_table_name` - DynamoDB table name
   - Additional service-specific variables as needed

4. Initialize and apply Terraform:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## License

MIT License - See [LICENSE](LICENSE) for details.