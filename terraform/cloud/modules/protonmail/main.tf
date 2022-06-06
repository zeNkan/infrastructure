resource "cloudflare_record" "records" {
  zone_id = var.cloudflare_zone_id

  name = lookup(var.proton_records[count.index], "key", null) == null ? var.domain_name : join(".", [var.proton_records[count.index].key, var.domain_name])

  value    = var.proton_records[count.index].value
  type     = var.proton_records[count.index].type
  priority = var.proton_records[count.index].priority

  count = length(var.proton_records)
}