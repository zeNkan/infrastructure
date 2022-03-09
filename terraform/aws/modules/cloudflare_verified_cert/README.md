# Terraform-Cloudflare-Verified-ACM-Cert
Terraform module to create ACM certificates verified via cloudflare DNS

## Prerequisites
For this module to work you will need the following prerequisites set up:
1. Exported credentials to Cloudflare with the permission to create DNS records 
   in your DNS zone.
2. AWS Cli setup with the permissions to create certificates.

## Getting Started
Getting started is really easy, all you need is to provide the module with the
hostname of the new service, and the domain name of the DNS zone in which the
new service will reside.

```hcl
module "cloudflare_verified_ACM_cert" {
  source = "github.com/zeNkan/Terraform-Cloudflare-Verified-ACM-Cert"

  hostname    = "test"
  domain_name = "example.com"
}
```

