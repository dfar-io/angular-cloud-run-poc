# VPC network used for static IP address
# https://cloud.google.com/run/docs/configuring/static-outbound-ip

resource "google_compute_network" "default" {
  project  = local.project_id
  provider = google-beta
  name     = "cr-static-ip-network"
}

resource "google_compute_subnetwork" "default" {
  project       = local.project_id
  provider      = google-beta
  name          = "cr-static-ip"
  ip_cidr_range = "10.124.0.0/28"
  network       = google_compute_network.default.id
  region        = "us-central1"
}

resource "google_project_service" "vpc" {
  project            = local.project_id 
  provider           = google-beta
  service            = "vpcaccess.googleapis.com"
  disable_on_destroy = false
}

resource "google_vpc_access_connector" "default" {
  project  = local.project_id
  provider = google-beta
  name     = "cr-conn"
  region   = "us-central1"

  subnet {
    name = google_compute_subnetwork.default.name
  }

  # Wait for VPC API enablement
  # before creating this resource
  depends_on = [
    google_project_service.vpc
  ]
}

resource "google_compute_router" "default" {
  project  = local.project_id
  provider = google-beta
  name     = "cr-static-ip-router"
  network  = google_compute_network.default.name
  region   = google_compute_subnetwork.default.region
}

# Static IP address
resource "google_compute_address" "default" {
  project  = local.project_id
  provider = google-beta
  name     = "cr-static-ip-addr"
  region   = google_compute_subnetwork.default.region
}

resource "google_compute_router_nat" "default" {
  project  = local.project_id
  provider = google-beta
  name     = "cr-static-nat"
  router   = google_compute_router.default.name
  region   = google_compute_subnetwork.default.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.default.self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.default.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

output "ip_address" {
  description = "IP Address"
  value       = google_compute_address.default.address
}