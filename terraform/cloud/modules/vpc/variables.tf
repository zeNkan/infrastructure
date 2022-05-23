variable "region" {
  description = "The region our VPC will reside in"
  type        = string
}

variable "vpc_name" {
  description = "Name of our VPC"
  type        = string
}

variable "vpc_cidr_range" {
  description = "VPC CIDR range"
  type        = string
}

variable "pub_subnets" {
  description = "List of cidr ranges for public subnets"
  type        = list(string)
}

variable "priv_subnets" {
  description = "List of cidr ranges for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}