output "pages_url" {
  description = "Cloudflare Pages default URL"
  value       = "https://${cloudflare_pages_project.site.name}.pages.dev"
}

output "nameservers" {
  description = "Set these nameservers in Porkbun"
  value       = cloudflare_zone.site.name_servers
}

output "custom_domain" {
  description = "Custom domain URL"
  value       = "https://alexeastlake.com"
}
