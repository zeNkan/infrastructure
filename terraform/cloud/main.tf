provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Set up domain
resource "cloudflare_zone" "root_zone" {
  zone = "backman.fyi"
}

module "protonmail" {
  source = "./modules/protonmail/"

  cloudflare_zone_id = cloudflare_zone.root_zone.id
  spf_record         = var.proton_spf
  dkim_record        = var.proton_dkim
}

module "vpc" {
  source = "./modules/vpc"

  region               = "eu-north-1"
  vpc_cidr_range             = "10.10.0.0/16"
  vpc_name                 = "main-vpc"
  pub_subnets  = ["10.10.0.0/24", "10.10.1.0/24", "10.10.2.0/24"]
  priv_subnets = ["10.10.3.0/24", "10.10.4.0/24", "10.10.5.0/24"]
  availability_zones   = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

module "minecraft-backup" {
  source = "./modules/minecraft-backup/"

  username = "mc-backup"
}

module "minecraft-status" {
  source = "./modules/minecraft-status/"

  ecr_repo_name = "minecraft-status"
  prefix        = "minecraft-status"
  image_tag     = "latest"
}

module "cloudflare_cert" {
  source = "./modules/cloudflare_verified_cert/"

  hostname    = "minecraft-status"
  domain_name = "backman.fyi"
}

module "api_gateway" {
  source      = "./modules/api_gateway/"
  hostname    = "minecraft-status"
  domain_name = "backman.fyi"
  lambda_name = module.minecraft-status.lambda_name
  lambda_arn  = module.minecraft-status.lambda_arn
  zone_name   = "backman.fyi"
  cert_arn    = module.cloudflare_cert.arn
}