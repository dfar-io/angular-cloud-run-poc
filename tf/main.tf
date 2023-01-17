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