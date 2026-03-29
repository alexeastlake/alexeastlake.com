terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# --- Zone ---

resource "cloudflare_zone" "site" {
  account = {
    id = var.cloudflare_account_id
  }

  name = "alexeastlake.com"
  type = "full"
}

# --- Pages ---
# NOTE: In v5, the GitHub source connection is read-only in Terraform.
# You must connect the repo to Cloudflare Pages manually in the dashboard
# (Workers & Pages → Create → Pages → Connect to Git) BEFORE running apply.
# Terraform will then manage the project config but not the Git connection.

resource "cloudflare_pages_project" "site" {
  account_id        = var.cloudflare_account_id
  name              = "alexeastlake-com"
  production_branch = "main"
}

# --- Custom domains ---

resource "cloudflare_pages_domain" "apex" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.site.name
  name         = "alexeastlake.com"
}

resource "cloudflare_pages_domain" "www" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.site.name
  name         = "www.alexeastlake.com"
}

# --- DNS records for Pages ---

resource "cloudflare_dns_record" "apex" {
  zone_id = cloudflare_zone.site.id
  name    = "@"
  type    = "CNAME"
  content = "${cloudflare_pages_project.site.name}.pages.dev"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "www" {
  zone_id = cloudflare_zone.site.id
  name    = "www"
  type    = "CNAME"
  content = "${cloudflare_pages_project.site.name}.pages.dev"
  proxied = true
  ttl     = 1
}
