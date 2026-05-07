# alexeastlake.com

Personal landing page. Deployed to [Cloudflare Pages](https://pages.cloudflare.com/).

## Structure

```
site/
  src/
    assets/images/   Gallery images (processed by Astro at build time)
    data/            Gallery data (gallery.json)
    layouts/         Base HTML layout
    pages/           Pages (index, gallery)
    styles/          CSS
  public/            Static assets served as-is (favicon, etc.)
terraform/           Infrastructure as code (Cloudflare)
```

## Deployment

Every push deploys automatically via Cloudflare Pages. The `main` branch is the production deployment at `alexeastlake.com`. Other branches get preview deployments on `*.pages.dev`, which are restricted by an access policy.

## Gallery

Gallery images live in `src/assets/images/` so Astro can optimise them at build time (resized to 600px wide, converted to WebP). The gallery data in `src/data/gallery.json` defines categories and image metadata. To add an image:

1. Drop the `.jpg` into `src/assets/images/`
2. Add an entry to the relevant category in `gallery.json`

Clicking an image in the gallery links to the optimised full-size version.

## Infrastructure

Managed with Terraform (Cloudflare provider v5). Resources:

- **Zone + DNS** — `alexeastlake.com` and `www` CNAME records
- **Pages project** — connected to this repo, serves `site/`
- **Custom domains** — `alexeastlake.com` and `www.alexeastlake.com`
- **Access policy** — `*.pages.dev` URLs restricted to owner only

### How a request reaches the site

```
Browser: "where is alexeastlake.com?"
       │
       ▼
Porkbun (registrar)
  Porkbun owns the domain registration. Its only job is telling the
  internet "ask Cloudflare's nameservers about alexeastlake.com."
       │
       ▼
Cloudflare Zone
  The zone is Cloudflare saying "I'm in charge of DNS for this domain."
  It's the container that holds all DNS records for alexeastlake.com.
       │
       ▼
DNS record
  Resolves the hostname to an IP address. The browser asked "where is
  alexeastlake.com?" and DNS answers with the IP of Cloudflare's Pages
  servers. The DNS record points at alexeastlake-com.pages.dev to reach
  the right servers, but this is just IP resolution — after this step,
  the pages.dev name is not part of the request. The browser still thinks
  it's talking to alexeastlake.com.
       │
       ▼
Traffic arrives at Cloudflare's Pages servers
  The HTTP request lands with the header "Host: alexeastlake.com".
  Pages hosts millions of projects, so it needs to figure out which
  one should handle this request.
       │
       ▼
Custom domain
  The lookup table that maps hostnames to projects. Pages checks:
  "does any project claim alexeastlake.com?" The custom domain entry
  says "yes, the alexeastlake-com project owns that hostname."
  Without this, Pages would not recognise alexeastlake.com and would
  return an error.
       │
       ▼
Pages project: serves site/index.html
```

The access policy blocks direct visits to `*.pages.dev` URLs. This works because
Cloudflare Access checks the hostname the browser is actually requesting. Traffic
via the custom domain arrives as `alexeastlake.com`, not `pages.dev`, so it passes
through freely.

### Setup

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Fill in values
terraform init
terraform apply
```

Required API token permissions: Zone Edit, DNS Edit, Cloudflare Pages Edit, Access Apps and Policies Edit.
