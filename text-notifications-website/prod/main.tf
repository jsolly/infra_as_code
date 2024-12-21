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

  asset_storage_bucket = var.asset_storage_bucket
  metadata_table_name  = var.metadata_table_name
  photo_fetcher_name   = var.photo_fetcher_name
  lambda_code_bucket   = var.lambda_code_bucket
  lambda_code_key      = var.lambda_code_key
  nasa_api_key         = var.nasa_api_key
  function_handler     = var.function_handler
  runtime              = var.runtime
  function_timeout     = var.function_timeout
  function_memory_size = var.function_memory_size
}

module "frontend" {
  source = "./frontend"

  domain_name          = var.domain_name
  website_bucket_name  = var.website_bucket_name
  asset_storage_bucket = var.asset_storage_bucket
  metadata_table_name  = var.metadata_table_name
  aws_region           = var.aws_region

  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id

  google_search_console_txt_record = var.google_search_console_txt_record
}
