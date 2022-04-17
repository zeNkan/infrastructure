variable "cloudflare_zone_id" {
  description = "The DNS zone we are adding the mail integration to"
  type = string
}

variable "spf_record" {
  description = "TXT record value"
  type = string
}

variable "dkim_record" {
  description = "TXT record value"
  type = string
}
