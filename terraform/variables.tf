variable "cloudflare_api_token" {
  description = "Cloudflare API token with Zone and Pages permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "owner_email" {
  description = "Email address allowed to access pages.dev preview URLs"
  type        = string
}
