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
  source = "../../modules/aws_plus_cloudflare/cloudflare"
  cloudflare_account_id = var.cloudflare_account_id
  cloudflare_zone_id    = var.cloudflare_zone_id
  domain_name           = var.domain_name
  bucket_name           = var.bucket_name
  aws_region            = var.aws_region
  google_search_console_txt_record = var.google_search_console_txt_record
}

// Add this data source to get the current region
data "aws_region" "current" {}

module "s3" {
  source                      = "../../modules/aws_plus_cloudflare/s3"
  bucket_name                 = var.bucket_name
  bucket_policy_type          = "cloudflare"
  enable_website_hosting      = true
  website_config = {
    index_document = "index.html"
    error_document = "500.html"
  }
}
