terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.0.0-alpha1"
    }
  }
}

resource "cloudflare_dns_record" "website" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  content   = "${var.bucket_name}.s3-website-${var.aws_region}.amazonaws.com"  # S3 website endpoint
  type    = "CNAME"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "www" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  content = var.domain_name
  type    = "CNAME"
  proxied = true
  ttl     = 1
} 

# Google Search Console TXT record
resource "cloudflare_dns_record" "google_search_console" {
  zone_id = var.cloudflare_zone_id
  name    = var.domain_name
  content = var.google_search_console_txt_record
  type    = "TXT"
  ttl     = 1
}
