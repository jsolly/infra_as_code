terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.0.0-alpha1"
    }
  }
}

# CNAME record for the apex domain pointing to S3 website endpoint
resource "cloudflare_dns_record" "website" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  type    = "CNAME"
  proxied = true
  ttl     = 1
}

# WWW subdomain that points to the apex domain
resource "cloudflare_dns_record" "www" {
  zone_id = var.cloudflare_zone_id
  name    = "www.${var.domain_name}"
  type    = "CNAME"
  proxied = true
  ttl     = 1
} 

# Google Search Console TXT record
resource "cloudflare_dns_record" "google_search_console" {
  zone_id = var.cloudflare_zone_id
  name    = var.domain_name
  type    = "TXT"
  ttl     = 1
}
