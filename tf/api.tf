# Creates Cloud Run container
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service#example-usage---cloud-run-service-basic
resource "google_cloud_run_service" "api" {
  project = local.project_id
  name     = "gcp-cloud-run-poc-api"
  location = "us-central1"
  # enables updates to the service
  autogenerate_revision_name = true

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        ports {
          container_port = 80
        }
        env {
          name  = "CONNECTION_STRING"
          value = "Data Source=${google_sql_database_instance.instance.private_ip_address};User Id=${google_sql_user.users.name};Password=${random_password.password.result};"
        }
      }
    }
    # needed for outbound static IP
    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.default.name
        "run.googleapis.com/vpc-access-egress"    = "all-traffic"
        "autoscaling.knative.dev/maxScale"        = "5"
        # currently not supported by .NET and Cloud Run
        #"run.googleapis.com/cloudsql-instances"   = google_sql_database_instance.instance.connection_name
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
      template[0].spec[0].containers[0].image,
      template[0].metadata[0].annotations["client.knative.dev/user-image"],
      template[0].metadata[0].annotations["run.googleapis.com/client-name"],
      template[0].metadata[0].annotations["run.googleapis.com/client-version"]
    ]
  }

  depends_on = [
    google_project_service.cloud_run
  ]
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