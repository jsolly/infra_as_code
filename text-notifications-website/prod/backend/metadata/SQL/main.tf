# Generate random password for the database
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store credentials in Parameter Store
resource "aws_ssm_parameter" "db_username" {
  name  = "/weather-notifications/${var.environment}/db/username"
  type  = "String"
  value = "${replace(var.website_bucket_name, ".", "_")}_${var.environment}_admin"

  tags = {
    Name        = "weather-notifications-${var.environment}-db-username"
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/weather-notifications/${var.environment}/db/password"
  type  = "SecureString"
  value = random_password.db_password.result

  tags = {
    Name        = "weather-notifications-${var.environment}-db-password"
    Environment = var.environment
  }
}

# VPC for the database
resource "aws_vpc" "db_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "weather-notifications-${var.environment}-vpc"
    Environment = var.environment
  }
}

# Private subnets for the database (no internet access needed)
resource "aws_subnet" "private_subnets" {
  count             = 2
  vpc_id            = aws_vpc.db_vpc.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "weather-notifications-${var.environment}-private-${count.index + 1}"
    Environment = var.environment
  }
}

# Route table for private subnets (local traffic only)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.db_vpc.id

  # No routes needed - will only use local VPC routing

  tags = {
    Name        = "weather-notifications-${var.environment}-private-rt"
    Environment = var.environment
  }
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private_rta" {
  count          = 2
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Aurora Serverless v2 Cluster
resource "aws_rds_cluster" "weather_notifications" {
  cluster_identifier = "weather-notifications-${var.environment}"
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"
  engine_version     = "14.5"
  database_name      = "weather_notifications"
  master_username    = aws_ssm_parameter.db_username.value
  master_password    = aws_ssm_parameter.db_password.value

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 1.0
  }

  vpc_security_group_ids = [aws_security_group.aurora_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name

  skip_final_snapshot = true

  tags = {
    Name        = "weather-notifications-${var.environment}"
    Environment = var.environment
  }
}

# Aurora Instance
resource "aws_rds_cluster_instance" "cluster_instances" {
  cluster_identifier = aws_rds_cluster.weather_notifications.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.weather_notifications.engine
  engine_version     = aws_rds_cluster.weather_notifications.engine_version

  tags = {
    Name        = "weather-notifications-${var.environment}"
    Environment = var.environment
  }
}

# Security Group
resource "aws_security_group" "aurora_sg" {
  name        = "aurora-security-group-${var.environment}"
  description = "Security group for Aurora Serverless cluster"
  vpc_id      = aws_vpc.db_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "weather-notifications-${var.environment}-aurora-sg"
    Environment = var.environment
  }
}

# Lambda Security Group
resource "aws_security_group" "lambda_sg" {
  name        = "lambda-security-group-${var.environment}"
  description = "Security group for Lambda functions accessing Aurora"
  vpc_id      = aws_vpc.db_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "weather-notifications-${var.environment}-lambda-sg"
    Environment = var.environment
  }
}

# Subnet Group
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group-${var.environment}"
  subnet_ids = aws_subnet.private_subnets[*].id

  tags = {
    Name        = "weather-notifications-${var.environment}-subnet-group"
    Environment = var.environment
  }
}

# Schema creation
resource "aws_rds_cluster_parameter_group" "custom_params" {
  family = "aurora-postgresql14"
  name   = "weather-notifications-params-${var.environment}"

  parameter {
    name  = "timezone"
    value = "UTC"
  }

  tags = {
    Name        = "weather-notifications-${var.environment}-params"
    Environment = var.environment
  }
}

# Create tables using a null_resource with local-exec provisioner
resource "null_resource" "schema_setup" {
  depends_on = [aws_rds_cluster_instance.cluster_instances]

  provisioner "local-exec" {
    command = <<-EOF
      PGPASSWORD=${aws_ssm_parameter.db_password.value} psql -h ${aws_rds_cluster.weather_notifications.endpoint} -U "${aws_ssm_parameter.db_username.value}" -d weather_notifications -f ${path.module}/schema.sql
    EOF
  }
}
