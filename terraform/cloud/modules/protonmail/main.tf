resource "cloudflare_record" "proton_mx_20" {
  zone_id = var.cloudflare_zone_id
  name    = "backman.fyi"
  value   = "mailsec.protonmail.ch"
  type    = "MX"
  priority = "20"
}

resource "cloudflare_record" "proton_mx_10" {
  zone_id = var.cloudflare_zone_id
  name    = "backman.fyi"
  value   = "mail.protonmail.ch"
  type    = "MX"
  priority = "10"
}

resource "cloudflare_record" "proton_spf" {
  zone_id = var.cloudflare_zone_id
  name    = "backman.fyi"
  value   = var.spf_record
  type    = "TXT"
}

resource "cloudflare_record" "proton_dkim" {
  zone_id = var.cloudflare_zone_id
  name    = "protonmail._domainkey"
  value   = var.dkim_record
  type    = "TXT"
}
