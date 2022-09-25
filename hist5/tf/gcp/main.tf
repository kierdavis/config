terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 4.35"
    }
    http = {
      source = "hashicorp/http"
      version = "~> 3.1"
    }
    local = {
      source = "hashicorp/local"
      version = "~> 2.2"
    }
  }
}

variable "cue" {
  type = any
}

locals {
  machines = {
    for name, machine in var.cue.machines :
    name => machine
    if lookup(machine, "gcpZone", null) != null
  }
}

resource "google_project" "main" {
  name = "hist5"
  project_id = "hist-5"
  org_id = var.cue.gcpOrganisationId
  billing_account = var.cue.gcpBillingAccountId
  auto_create_network = false
  skip_delete = true
}

resource "google_storage_bucket" "image_upload" {
  project = google_project.main.project_id
  name = "hist5-image-upload"
  location = var.cue.gcpRegion
  force_destroy = true
  storage_class = "STANDARD"
  uniform_bucket_level_access = true
}

#resource "google_storage_bucket_object" "talos" {
#  bucket = google_storage_bucket.image_upload.name
#  name = "talos-${var.cue.versions.talos}-gcp-amd64.tar.gz"
#  # https://github.com/siderolabs/talos/releases
#  source = "../artifacts/talos-${var.cue.versions.talos}-gcp-amd64.tar.gz"
#}
data "google_storage_bucket_object" "talos" {
  bucket = google_storage_bucket.image_upload.name
  name = "talos-${var.cue.versions.talos}-gcp-amd64.tar.gz"
}

# TODO: set the image's location to local.gcp_region.
# Currently it defaults to `eu`.
# Pending https://github.com/GoogleCloudPlatform/magic-modules/pull/5834
resource "google_compute_image" "talos" {
  project = google_project.main.project_id
  name = "talos-${replace(var.cue.versions.talos,".","-")}"
  description = "Talos Linux v${var.cue.versions.talos}"
  family = "talos"
  raw_disk {
    container_type = "TAR"
    source = data.google_storage_bucket_object.talos.self_link
  }
  guest_os_features {
    type = "UEFI_COMPATIBLE"
  }
}

resource "google_compute_network" "talos" {
  project = google_project.main.project_id
  name = "talos"
  auto_create_subnetworks = false
  mtu = var.cue.networks.gcpMachines.mtu
}

resource "google_compute_subnetwork" "talos" {
  project = google_project.main.project_id
  network = google_compute_network.talos.self_link
  name = "talos"
  region = var.cue.gcpRegion
  ip_cidr_range = var.cue.networks.gcpMachines.cidr
}

data "http" "my_ip" {
  url = "https://ifconfig.co/"
}

resource "google_compute_firewall" "talos_api_bootstrap" {
  project = google_project.main.project_id
  network = google_compute_network.talos.self_link
  name = "talos-api-bootstrap"
  direction = "INGRESS"
  source_ranges = ["${chomp(data.http.my_ip.body)}/32"]
  allow {
    protocol = "TCP"
    ports = [50000]
  }
}

resource "google_compute_firewall" "wireguard" {
  project = google_project.main.project_id
  network = google_compute_network.talos.self_link
  name = "wireguard"
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "UDP"
    ports = [var.cue.networks.wireguard.listenPort]
  }
}

resource "google_compute_address" "talos" {
  for_each = local.machines
  project = google_project.main.project_id
  region = var.cue.gcpRegion
  name = each.key
  address_type = "EXTERNAL"
  network_tier = "STANDARD"
}

resource "google_compute_disk" "os" {
  for_each = local.machines
  project = google_project.main.project_id
  zone = each.value.gcpZone
  name = "${each.key}-os"
  type = "pd-balanced"
  size = 20
  image = google_compute_image.talos.self_link
}

resource "google_compute_disk" "ceph_std1" {
  for_each = local.machines
  project = google_project.main.project_id
  zone = each.value.gcpZone
  name = "${each.key}-ceph-std1"
  type = "pd-standard"
  size = 682
}

resource "google_compute_resource_policy" "os_snapshot" {
  project = google_project.main.project_id
  region = var.cue.gcpRegion
  name = "talos-os-disk-snapshot"
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time = "08:00"
      }
    }
    retention_policy {
      max_retention_days = 7
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
    snapshot_properties {
      storage_locations = [var.cue.gcpRegion]
      guest_flush = true
    }
  }
}

resource "google_compute_disk_resource_policy_attachment" "os_snapshot" {
  for_each = local.machines
  project = google_project.main.project_id
  name = google_compute_resource_policy.os_snapshot.name
  disk = google_compute_disk.os[each.key].name
  zone = each.value.gcpZone
}

resource "google_compute_instance" "talos" {
  for_each = local.machines
  project = google_project.main.project_id
  zone = each.value.gcpZone
  name = each.key
  machine_type = each.key == "talosgcp3" ? "e2-standard-4" : "e2-highmem-2"
  desired_status = "RUNNING"
  boot_disk {
    source = google_compute_disk.os[each.key].self_link
    device_name = "os"
    mode = "READ_WRITE"
    auto_delete = false
  }
  attached_disk {
    source = google_compute_disk.ceph_std1[each.key].self_link
    device_name = "ceph-std1"
    mode = "READ_WRITE"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.talos.self_link
    access_config {
      nat_ip = google_compute_address.talos[each.key].address
      network_tier = google_compute_address.talos[each.key].network_tier
    }
  }
  metadata = {
    "serial-port-enable" = "true"
  }
}

resource "local_file" "output" {
  filename = "../cue/autogenerated_gcp.cue"
  file_permission = "0644"
  content = join("\n", ["package hist5", jsonencode({
    machines = {
      for name, address in google_compute_address.talos :
      name => {
        addresses = {
          gcpMachines = google_compute_instance.talos[name].network_interface.0.network_ip
          internet = address.address
        }
      }
    }
  })])
}
