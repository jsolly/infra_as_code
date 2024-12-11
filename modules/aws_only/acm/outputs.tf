output "certificate_arn" {
  value       = aws_acm_certificate.cert.arn
  description = "ARN of the certificate"
}

output "zone_id" {
  value       = aws_route53_zone.zone.id
  description = "ID of the Route53 zone"
}

output "name_servers" {
  value       = aws_route53_zone.zone.name_servers
  description = "Name servers of the Route53 zone"
} 