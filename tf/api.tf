# Creates Cloud Run container
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service#example-usage---cloud-run-service-basic
resource "google_cloud_run_service" "api" {
  project = local.project_id
  name     = "gcp-cloud-run-poc-api"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        ports {
          container_port = 5000
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Ignore changes to image after creation
  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image
    ]
  }
}

# Allows public access
data "google_iam_policy" "noauth_api" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers"
    ]
  }
}
resource "google_cloud_run_service_iam_policy" "noauth_api" {
  location    = google_cloud_run_service.api.location
  project     = local.project_id
  service     = google_cloud_run_service.api.name

  policy_data = data.google_iam_policy.noauth_api.policy_data
}

# Outputs URL after apply
output "cloud_run_url_api" {
  description = "Cloud Run URL (API)"
  value       = google_cloud_run_service.api.status[0].url
}