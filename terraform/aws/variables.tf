# General settings
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-north-1"
}

# Packer VPC
variable "packer_build_env" {
  description = "Base name for the packer build environment"
  type        = string
  default     = "packer-build"
}
variable "packer_build_vpc_cidr" {
  description = "Packer build VPC cidr range"
  type        = string
  default     = "172.88.0.0/16"
}


