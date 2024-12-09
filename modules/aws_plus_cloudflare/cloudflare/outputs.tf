output "website_dns_record" {
  description = "The DNS record for the website"
  value       = cloudflare_dns_record.website
}

output "www_dns_record" {
  description = "The DNS record for the www subdomain (if created)"
  value       = cloudflare_dns_record.www
} 