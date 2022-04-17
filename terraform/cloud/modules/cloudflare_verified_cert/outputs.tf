output "arn" {
  description = "Certificate ARN"
  value = aws_acm_certificate_validation.CF_verified.certificate_arn
}

output "zone_id" {
  description = "Cloudflare DNS zone ID"
  value = data.cloudflare_zones.backman.zones[0].id
}
