# AWS
variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "aws_vpc_name" {
  description = "Name of AWS root VPC"
  type        = string
}

variable "aws_vpc_cidr_range" {
  type = string
}
variable "aws_availability_zones" {
  type = list(string)
}

variable "aws_public_subnets" {
  type = list(string)
}

variable "aws_private_subnets" {
  type = list(string)
}

# PROTON MAIL
variable "proton_spf" {
  description = "Protonmail SPF record"
  type        = string
}

variable "proton_dkim" {
  description = "Protonmail DKIM record"
  type        = string
}


# CLOUDFLARE
variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
}

variable "cloudflare_dns_zone" {
  description = "DNS zone to be registered in Cloudflare"
  type        = string
}

# MC BACKUP
variable "mc_backup_username" {
  description = "MC Backup AWS IAM User"
  type        = string
}

# MINECRAFT-STATUS
variable "mc_status_function_name" {
  description = "Minecraft Status Function Name"
  type        = string
}

variable "mc_status_server_hostname" {
  description = "MC Server Hostname"
  type        = string
}
# MINECRAFT-STATUS
variable "mc_status_server_port" {
  description = "MC Server Port"
  type        = string
}
