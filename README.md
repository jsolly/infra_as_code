
## Reusable Modules

### S3 Module (`modules/s3`)
- Creates and configures S3 buckets for content storage
- Configures bucket policies for secure access
- Manages public access settings

### CloudFront Module (`modules/cloudfront`)
- Sets up CloudFront distributions with Origin Access Control
- Configures custom error responses
- Includes CloudFront Functions for URL handling and redirects
- Supports HTTP/2 and HTTP/3
- Enforces HTTPS with TLS 1.2

### Route53 Module (`modules/route53`)
- Manages DNS records for domains and subdomains
- Creates A and AAAA records for CloudFront distributions
- Supports alias records for optimal routing

## Adding a New Website

1. Create a new directory for your site
2. Create environment sub-directories (e.g., prod, dev)
3. Configure the following files:
   - `main.tf` - Module configurations
   - `variables.tf` - Variable definitions
   - `terraform.tfvars` - Variable values

## Prerequisites

- AWS Account
- Terraform ~> 5.0

## Usage

1. Configure your AWS credentials
2. Navigate to your website's environment directory:
   ```bash
   cd your-website/prod
   ```

3. Update the variables in your environment's tfvars file:
   - `certificate_arn`
   - `domain_name`
   - `bucket_name`

4. Initialize and apply Terraform:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## License

MIT License - See [LICENSE](LICENSE) for details.