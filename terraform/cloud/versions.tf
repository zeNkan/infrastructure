terraform {

  backend "s3" {
    bucket = "backman-tf-state"
    key    = "tf.state"
    region = "eu-north-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "> 2.0.0"
    }
  }

  required_version = ">= 0.13"
}
