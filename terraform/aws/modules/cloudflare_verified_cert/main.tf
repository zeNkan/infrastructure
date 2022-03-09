# Domain to be used
data "cloudflare_zones" "backman" {
  filter {
    name = var.domain_name
  }
}

# Create Certificate for the FQDN of our desided domain
resource "aws_acm_certificate" "new_cert" {
  domain_name       = "${var.hostname}.${var.domain_name}"
  validation_method = "DNS"
}

# Create records to verify our ownership
resource "cloudflare_record" "cert_verification" {
  for_each = {
    for dvo in aws_acm_certificate.new_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = data.cloudflare_zones.backman.zones[0].id
  name            = each.value.name
  value           = trimsuffix(each.value.record, ".")
  type            = each.value.type
  ttl             = 1
  proxied         = false
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "CF_verified" {
  certificate_arn         = aws_acm_certificate.new_cert.arn
  validation_record_fqdns = [for record in cloudflare_record.cert_verification : record.hostname]
}
