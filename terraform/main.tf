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

resource "cloudflare_pages_project" "site" {
  account_id        = var.cloudflare_account_id
  name              = "alexeastlake-com"
  production_branch = "main"

  source = {
    type = "github"
    config = {
      owner                         = "alexeastlake"
      repo_name                     = "alexeastlake.com"
      production_branch             = "main"
      production_deployments_enabled = true
      pr_comments_enabled           = true
      preview_deployment_setting    = "all"
    }
  }

  build_config = {
    destination_dir = "site"
  }
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

# --- Block public access to *.pages.dev ---

resource "cloudflare_zero_trust_access_application" "pages_dev" {
  account_id = var.cloudflare_account_id
  name       = "Block pages.dev access"
  domain     = "${cloudflare_pages_project.site.name}.pages.dev"
  type       = "self_hosted"

  policies = [
    {
      name       = "Allow owner"
      decision   = "allow"
      precedence = 1
      include = [{
        email = {
          email = var.owner_email
        }
      }]
    },
    {
      name       = "Block public"
      decision   = "deny"
      precedence = 2
      include = [{
        everyone = {}
      }]
    }
  ]
}
