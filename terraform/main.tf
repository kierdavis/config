terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

provider "cloudflare" {
  email = local.hist2_secret.api.cloudflare.email
  api_key = local.hist2_secret.api.cloudflare.api_key
}

locals {
  beagle2_ipv4 = "176.9.121.81"
}

locals {
  hist2_secret = jsondecode(sensitive(file("../secret/hist2.json")))
}

resource "cloudflare_record" "kierdavis_com_a" {
  zone_id = local.hist2_secret.api.cloudflare.zone_ids.kierdavis_com
  name = "kierdavis.com"
  type = "A"
  value = local.beagle2_ipv4
  proxied = true
}

resource "cloudflare_record" "www_kierdavis_com_a" {
  zone_id = local.hist2_secret.api.cloudflare.zone_ids.kierdavis_com
  name = "www"
  type = "A"
  value = local.beagle2_ipv4
  proxied = true
}

resource "cloudflare_record" "git_kierdavis_com_a" {
  zone_id = local.hist2_secret.api.cloudflare.zone_ids.kierdavis_com
  name = "git"
  type = "A"
  value = local.beagle2_ipv4
  proxied = false
}

# TODO update these: https://support.google.com/a/answer/140034
resource "cloudflare_record" "kierdavis_com_mx" {
  for_each = {
    "0" = {
      value = "aspmx.l.google.com"
      priority = 1
    }
    "1" = {
      value = "alt1.aspmx.l.google.com"
      priority = 5
    }
    "2" = {
      value = "aspmx2.googlemail.com"
      priority = 10
    }
  }
  zone_id = local.hist2_secret.api.cloudflare.zone_ids.kierdavis_com
  name = "kierdavis.com"
  type = "MX"
  value = each.value.value
  priority = each.value.priority
}
