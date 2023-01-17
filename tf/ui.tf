# Creates Cloud Run container
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service#example-usage---cloud-run-service-basic
resource "google_cloud_run_service" "ui" {
  project = local.project_id
  name     = "gcp-cloud-run-poc-ui"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        ports {
          container_port = 4200
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
data "google_iam_policy" "noauth_ui" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers"
    ]
  }
}
resource "google_cloud_run_service_iam_policy" "noauth_ui" {
  location    = google_cloud_run_service.ui.location
  project     = local.project_id
  service     = google_cloud_run_service.ui.name

  policy_data = data.google_iam_policy.noauth_ui.policy_data
}

# Outputs URL after apply
output "cloud_run_url_ui" {
  description = "Cloud Run URL (UI)"
  value       = google_cloud_run_service.ui.status[0].url
}