resource "google_sql_database_instance" "instance" {
  name             = "cloudrun-sql"
  region           = "us-central1"
  database_version = "SQLSERVER_2019_EXPRESS"
  # both required for MS SQL, can be randomized
  root_password    = "changeme"

  settings {
    tier = "db-custom-2-3840"
    ip_configuration {
      authorized_networks {
        name  = "CloudRun"
        value = "${google_compute_address.default.address}/32"
      }
    }
  }
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