variable "lambda_name" {
  description = "The name of the lambda to trigger"
  type        = string
}

variable "lambda_arn" {
  description = "The arn of the lambda to trigger"
  type        = string
}

variable "domain_name" {
  description = "The domain name of the published app"
  type        = string
}

variable "hostname" {
  description = "The hostname of the published app"
  type        = string
}

variable "zone_name" {
  description = "The name of the Cloudlare DNS zone to which the hostname will belong"
  type        = string
}

variable "cert_arn" {
  description = "The arn of the cert created"
  type        = string
}
#module.cloudflare_verified_ACM_cert.arn

