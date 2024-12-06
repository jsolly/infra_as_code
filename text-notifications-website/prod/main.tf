terraform {
  backend "s3" {
    bucket         = "jsolly-general-tf-state"
    key            = "prod/text-notifications/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"

    assume_role = {
      role_arn = "arn:aws:iam::541310242108:role/TerraformStateBucketAccess"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "prod-admin"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "acm" {
  source      = "../../modules/acm"
  domain_name = var.domain_name
  zone_id     = var.cloudflare_zone_id
}

module "cloudfront" {
  source             = "../../modules/cloudfront"
  bucket_domain_name = module.s3.bucket_domain_name
  bucket_id          = module.s3.bucket_id
  certificate_arn    = module.acm.certificate_arn
  domain_names       = [var.domain_name, "www.${var.domain_name}"]
}

module "s3" {
  source                      = "../../modules/s3"
  bucket_name                 = var.bucket_name
  cloudfront_distribution_arn = module.cloudfront.distribution_arn
}

module "route53" {
  source                    = "../../modules/route53"
  domain_name               = var.domain_name
  cloudfront_domain_name    = module.cloudfront.domain_name
  bucket_name               = var.bucket_name
  cloudfront_hosted_zone_id = module.cloudfront.hosted_zone_id
}
