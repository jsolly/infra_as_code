module "lambda_code_storage" {
  source              = "./storage"
  storage_bucket_name = "${var.website_bucket_name}-${var.environment}-lambda-code"
  environment         = var.environment
}

module "metadata-nosql" {
  source              = "./metadata/NOSQL"
  website_bucket_name = var.website_bucket_name
  environment         = var.environment
}

# VPC for Lambda functions
# resource "aws_vpc" "lambda_vpc" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_hostnames = true
#   enable_dns_support   = true

#   tags = {
#     Name        = "weather-notifications-${var.environment}-vpc"
#     Environment = var.environment
#   }
# }

# # Private subnets for Lambda functions
# resource "aws_subnet" "private_subnets" {
#   count             = 2
#   vpc_id            = aws_vpc.lambda_vpc.id
#   cidr_block        = "10.0.${count.index + 10}.0/24"
#   availability_zone = data.aws_availability_zones.available.names[count.index]

#   tags = {
#     Name        = "weather-notifications-${var.environment}-private-${count.index + 1}"
#     Environment = var.environment
#   }
# }

# # Data source for availability zones
# data "aws_availability_zones" "available" {
#   state = "available"
# }

# # Route table for private subnets to allow outbound internet access
# resource "aws_route_table" "private_rt" {
#   vpc_id = aws_vpc.lambda_vpc.id

#   tags = {
#     Name        = "weather-notifications-${var.environment}-private-rt"
#     Environment = var.environment
#   }
# }

# # Associate private subnets with route table
# resource "aws_route_table_association" "private_rta" {
#   count          = 2
#   subnet_id      = aws_subnet.private_subnets[count.index].id
#   route_table_id = aws_route_table.private_rt.id
# }

# # Security group for Lambda functions
# resource "aws_security_group" "lambda_sg" {
#   name        = "lambda-security-group-${var.environment}"
#   description = "Security group for Lambda functions"
#   vpc_id      = aws_vpc.lambda_vpc.id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name        = "weather-notifications-${var.environment}-lambda-sg"
#     Environment = var.environment
#   }
# }

module "functions" {
  source                         = "./functions"
  website_bucket_name            = var.website_bucket_name
  nasa_api_key                   = var.nasa_api_key
  lambda_code_storage_bucket_arn = module.lambda_code_storage.bucket_arn
  metadata_table_arn             = module.metadata-nosql.table_arn
  twilio_account_sid             = var.twilio_account_sid
  twilio_auth_token              = var.twilio_auth_token
  twilio_sender_phone_number     = var.twilio_sender_phone_number
  twilio_target_phone_number     = var.twilio_target_phone_number
  # private_subnet_ids             = aws_subnet.private_subnets[*].id
  # lambda_security_group_id       = aws_security_group.lambda_sg.id
}
