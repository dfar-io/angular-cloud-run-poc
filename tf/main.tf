terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.48.0"
    }
  }
}

locals {
    project_id = "angular-cloud-run-poc"
}

provider "google" {
  # replace this with your GCP Project ID
  project = local.project_id
  region  = "us-central1"
  zone    = "us-central1-c"
}

# Creates Cloud Run container
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service#example-usage---cloud-run-service-basic
resource "google_cloud_run_service" "default" {
  project = local.project_id
  name     = "angular-cloud-run-poc-ui"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Allows public access
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers"
    ]
  }
}
resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

# Outputs URL after apply
output "cloud_run_url" {
  description = "Cloud Run URL"
  value       = google_cloud_run_service.default.status[0].url
}