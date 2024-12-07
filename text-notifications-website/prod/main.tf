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
      version = "5.0.0-alpha1"
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

module "cloudflare" {
  source = "../../modules/cloudflare"
  
  cloudflare_zone_id   = var.cloudflare_zone_id
  domain_name          = var.domain_name
  s3_website_endpoint  = "${var.bucket_name}.s3-website-${data.aws_region.current.name}.amazonaws.com"
  google_search_console_txt_record = var.google_search_console_txt_record
  cloudflare_api_token = var.cloudflare_api_token
}

// Add this data source to get the current region
data "aws_region" "current" {}

module "s3" {
  source                      = "../../modules/s3"
  bucket_name                 = var.bucket_name
  bucket_policy_type          = "cloudflare"
}
