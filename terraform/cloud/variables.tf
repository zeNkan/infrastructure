# General settings
variable "aws_region" {
  description = "AWS Region"
  type        = string
}

# PROTON MAIL
variable "proton_spf" {
  description = "Protonmail SPF record"
  type = string
}

variable "proton_dkim" {
  description = "Protonmail DKIM record"
  type = string
}
# Packer VPC
variable "packer_build_env" {
  description = "Base name for the packer build environment"
  type        = string
}
variable "packer_build_vpc_cidr" {
  description = "Packer build VPC cidr range"
  type        = string
}


variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
}
