terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
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
  account_id = var.cloudflare_account_id
  name       = "${var.widget_name}-${var.environment}"
  domains    = local.domains
  mode       = var.mode
}
