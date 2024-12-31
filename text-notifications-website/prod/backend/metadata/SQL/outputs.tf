output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.db_vpc.id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private_subnets[*].id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public_subnets[*].id
}

output "cluster_endpoint" {
  description = "The cluster endpoint"
  value       = aws_rds_cluster.weather_notifications.endpoint
}

output "reader_endpoint" {
  description = "The cluster reader endpoint"
  value       = aws_rds_cluster.weather_notifications.reader_endpoint
}

output "database_name" {
  description = "The database name"
  value       = aws_rds_cluster.weather_notifications.database_name
}

output "port" {
  description = "The database port"
  value       = aws_rds_cluster.weather_notifications.port
}
