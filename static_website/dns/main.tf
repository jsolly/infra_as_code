terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.0.0-alpha1"
    }
  }
}

resource "cloudflare_dns_record" "cname_root" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  content = "${var.website_bucket_name}.s3-website-${var.aws_region}.amazonaws.com"
  type    = "CNAME"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "cname_www" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  content = "www.${var.website_bucket_name}.s3-website-${var.aws_region}.amazonaws.com"
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
