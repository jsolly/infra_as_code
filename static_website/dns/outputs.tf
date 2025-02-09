output "cname_root_dns_record" {
  description = "The DNS record for the website"
  value       = cloudflare_dns_record.cname_root
}

output "cname_www_dns_record" {
  description = "The DNS record for the www subdomain (if created)"
  value       = cloudflare_dns_record.cname_www
}
