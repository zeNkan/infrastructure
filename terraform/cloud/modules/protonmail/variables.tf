variable "domain_name" {
  description = "Name of mail domain"
  type        = string
}

variable "proton_records" {
  description = "Domain to connect MX records to"
  type        = list(map(string))
}
variable "cloudflare_zone_id" {
  description = "The DNS zone we are adding the mail integration to"
  type        = string
}