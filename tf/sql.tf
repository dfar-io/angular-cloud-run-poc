resource "google_sql_database_instance" "instance" {
  name             = "cloudrun-sql"
  region           = "us-central1"
  database_version = "SQLSERVER_2019_EXPRESS"
  # both required for MS SQL, can be randomized
  root_password    = "changeme"

  settings {
    tier = "db-custom-2-3840"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.default.id
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_sql_user" "users" {
  name     = "app"
  instance = google_sql_database_instance.instance.name
  password = random_password.password.result
}

# private IP configuration
resource "google_compute_global_address" "private_ip_address" {
  project  = local.project_id
  provider = google-beta

  name          = "cloud-sql-private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.default.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = google_compute_network.default.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  depends_on = [google_project_service.service_networking]
}

resource "google_project_service" "service_networking" {
  project = local.project_id
  service = "servicenetworking.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}