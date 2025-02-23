terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

locals {
  domains = [
    var.domain_name,
    "www.${var.domain_name}"
  ]
}

resource "cloudflare_turnstile_widget" "widget" {
  name       = "${var.widget_name}-${var.environment}"
  account_id = var.cloudflare_account_id
  domains    = local.domains
  mode       = var.mode
}
