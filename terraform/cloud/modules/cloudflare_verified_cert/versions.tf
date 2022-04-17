terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.27"
    }
    cloudflare = { 
      source = "cloudflare/cloudflare"
      version = "> 2.0.0"
    }
  }

  required_version = ">= 0.13"
}
