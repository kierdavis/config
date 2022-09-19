terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 3.23.0"
    }
  }
}

variable "cue" {
  type = any
}

locals {
  beagle2_ipv4 = "176.9.121.81"
}

resource "cloudflare_record" "kierdavis_com_a" {
  zone_id = var.cue.cloudflare.zoneIds.kierdavisCom
  name = "kierdavis.com"
  type = "A"
  value = local.beagle2_ipv4
  proxied = true
}

resource "cloudflare_record" "www_kierdavis_com_a" {
  zone_id = var.cue.cloudflare.zoneIds.kierdavisCom
  name = "www"
  type = "A"
  value = local.beagle2_ipv4
  proxied = true
}

resource "cloudflare_record" "git_kierdavis_com_a" {
  zone_id = var.cue.cloudflare.zoneIds.kierdavisCom
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
  zone_id = var.cue.cloudflare.zoneIds.kierdavisCom
  name = "kierdavis.com"
  type = "MX"
  value = each.value.value
  priority = each.value.priority
}
