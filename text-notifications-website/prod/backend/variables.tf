variable "website_bucket_name" {
  type        = string
  description = "Base name of the website bucket"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., prod, dev, staging)"
  default     = "prod"
}

variable "nasa_api_key" {
  type        = string
  description = "API key for the NASA photo service"
  sensitive   = true
}

variable "twilio_account_sid" {
  type        = string
  description = "Twilio account SID"
  sensitive   = true
}

variable "twilio_auth_token" {
  type        = string
  description = "Twilio auth token"
  sensitive   = true
}

variable "twilio_phone_number" {
  type        = string
  description = "Twilio phone number"
  sensitive   = true
}

variable "target_phone_number" {
  type        = string
  description = "Target phone number"
  sensitive   = true
}
