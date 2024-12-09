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
  content   = "${var.bucket_name}.s3-website-${var.aws_region}.amazonaws.com"
  type    = "CNAME"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "www" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  content = "www.${var.bucket_name}.s3-website-${var.aws_region}.amazonaws.com"
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

# resource "cloudflare_worker_script" "append_index" {
#   name    = "${var.domain_name}-append-index"
#   content = file("${path.module}/functions/append-index.js")

#   plain_text_binding {
#     name = "ENVIRONMENT"
#     text = var.environment
#   }
# }

# resource "cloudflare_worker_route" "append_index_route" {
#   zone_id     = var.zone_id
#   pattern     = "/*"
#   script_name = cloudflare_worker_script.append_index.name
# }
