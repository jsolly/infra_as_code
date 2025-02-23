output "site_key" {
  description = "The site key for the Turnstile widget"
  value       = cloudflare_turnstile_widget.widget.site_key
}

output "secret_key" {
  description = "The secret key for the Turnstile widget"
  value       = cloudflare_turnstile_widget.widget.secret_key
  sensitive   = true
}
