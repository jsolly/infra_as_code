variable "widget_name" {
  description = "The name of the Turnstile widget"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
  default     = "prod"
}

variable "domain_name" {
  description = "Domain name for CORS configuration (e.g. textnotifications.app)"
  type        = string
}

variable "mode" {
  description = "The mode of the Turnstile widget (e.g., managed, invisible, non-interactive)"
  type        = string
  default     = "managed"
}

variable "cloudflare_account_id" {
  description = "The Cloudflare account ID"
  type        = string
  sensitive   = true
}
