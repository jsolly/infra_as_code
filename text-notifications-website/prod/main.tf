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

module "backend" {
  source = "./backend"

  website_bucket_name = var.website_bucket_name
  nasa_api_key        = var.nasa_api_key
  twilio_account_sid  = var.twilio_account_sid
  twilio_auth_token   = var.twilio_auth_token
  twilio_phone_number = var.twilio_phone_number
  target_phone_number = var.target_phone_number
}

# Frontend configuration
module "cloudflare" {
  source                           = "../../modules/frontend/aws_plus_cloudflare/cloudflare"
  cloudflare_zone_id               = var.cloudflare_zone_id
  domain_name                      = var.domain_name
  website_bucket_name              = var.website_bucket_name
  aws_region                       = var.aws_region
  google_search_console_txt_record = var.google_search_console_txt_record
}

module "website_buckets" {
  source              = "../../modules/frontend/aws_plus_cloudflare/s3"
  website_bucket_name = var.domain_name
  website_config = {
    index_document = "index.html"
    error_document = "500.html"
  }
}
