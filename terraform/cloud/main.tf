provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Set up domain
resource "cloudflare_zone" "root_zone" {
  zone = var.cloudflare_dns_zone
}

module "vpc" {
  source = "./modules/vpc"

  region             = var.aws_region
  vpc_cidr_range     = var.aws_vpc_cidr_range
  vpc_name           = var.aws_vpc_name
  pub_subnets        = var.aws_public_subnets
  priv_subnets       = var.aws_private_subnets
  availability_zones = var.aws_availability_zones
}

module "minecraft-backup" {
  source = "./modules/minecraft-backup/"

  username = var.mc_backup_username
}

module "minecraft-status" {
  source = "./modules/minecraft-status/"

  function_name      = var.mc_status_function_name
  image_tag          = "latest"
  mc_server_hostname = var.mc_status_server_hostname
  mc_server_port     = var.mc_status_server_port
}

module "cloudflare_cert" {
  source = "./modules/cloudflare_verified_cert/"

  hostname    = var.mc_status_function_name
  domain_name = var.cloudflare_dns_zone
}

module "api_gateway" {
  source      = "./modules/api_gateway/"
  hostname    = var.mc_status_function_name
  domain_name = var.cloudflare_dns_zone
  lambda_name = module.minecraft-status.lambda_name
  lambda_arn  = module.minecraft-status.lambda_arn
  zone_name   = var.cloudflare_dns_zone
  cert_arn    = module.cloudflare_cert.arn
}

module "protonmail" {
  source = "./modules/protonmail/"

  cloudflare_zone_id = cloudflare_zone.root_zone.id
  spf_record         = var.proton_spf
  dkim_record        = var.proton_dkim
}