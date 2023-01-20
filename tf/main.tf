terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.48.0"
    }
  }
}

locals {
  # replace this with your GCP Project ID
  project_id = "gcp-cloud-run-poc"
}

provider "google" {
  project = local.project_id
  region  = "us-central1"
  zone    = "us-central1-c"
}

# Enable APIs automatically
resource "google_project_service" "cloud_run" {
  project = local.project_id
  service = "run.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

resource "google_project_service" "compute_engine" {
  project = local.project_id
  service = "compute.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

resource "google_project_service" "cloud_build" {
  project = local.project_id
  service = "cloudbuild.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}