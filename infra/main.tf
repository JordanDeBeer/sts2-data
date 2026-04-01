terraform {
  backend "gcs" {
    bucket = "sts2-tfstate" # Replace with your bucket name
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.24.0"
    }
  }
}

provider "google" {
  region  = var.region
  project = var.project_id
}


resource "google_project_service" "bigquery" {
  project = var.project_id
  service = "bigquery.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "secretmanager" {
  project = var.project_id
  service = "secretmanager.googleapis.com"

  disable_on_destroy = false
}


resource "google_bigquery_dataset_iam_member" "member" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  role       = "roles/bigquery.dataOwner"
  member     = "serviceAccount:${google_service_account.api_sa.email}"
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id    = var.dataset_id
  friendly_name = "slaythespire2"
  description   = "Dataset for STS2 data"
  location      = var.region

  depends_on = [google_project_service.bigquery]
}


resource "google_bigquery_table" "table" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "runs"
  schema     = <<EOF
  [
      {
          "name": "steamid",
          "type": "STRING",
          "mode": "REQUIRED"
      },
      {
          "name": "run",
          "type": "TIMESTAMP",
          "mode": "REQUIRED"
      },
      {
          "name": "data",
          "type": "JSON",
          "mode": "REQUIRED"
      }
  ]
EOF

  deletion_protection = false # Set to true for production
}

resource "google_service_account" "api_sa" {
  account_id   = "api-service-account"
  display_name = "API Service Account"
}

resource "random_password" "jwtsecretkey" {
  length = 32
}

# Create the secret metadata
resource "google_secret_manager_secret" "jwtsecretkey" {
  secret_id = "jwtsecretkey"
  replication {
    auto {}
  }
}

# Store the generated password as a secret version
resource "google_secret_manager_secret_version" "jwtsecretkey_version" {
  secret      = google_secret_manager_secret.jwtsecretkey.id
  secret_data = random_password.jwtsecretkey.result
}

resource "google_secret_manager_secret_iam_member" "default" {
  secret_id = google_secret_manager_secret.jwtsecretkey.id
  role      = "roles/secretmanager.secretAccessor"
  # Grant the new deployed service account access to this secret.
  member     = "serviceAccount:${google_service_account.api_sa.email}"
  depends_on = [google_secret_manager_secret.jwtsecretkey]
}

resource "google_cloud_run_v2_service" "api" {
  name                 = "api"
  location             = var.region
  deletion_protection  = false
  invoker_iam_disabled = true

  scaling {
    max_instance_count = 1
  }

  template {
    service_account = google_service_account.api_sa.email
    containers {
      image = "us-central1-docker.pkg.dev/sts2-490800/sts2/api@sha256:a26822b6d079c4596240ce300a677e993396a2b9eeb1b7cae10c425704f4fcdf"
      env {
        name  = "BQ_DATASET"
        value = google_bigquery_dataset.dataset.dataset_id
      }
      env {
        name  = "BQ_TABLE"
        value = google_bigquery_table.table.table_id
      }
      env {
        name = "SECRET_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.jwtsecretkey.id
            version = "latest"
          }
        }
      }
      resources {
        limits = {
          cpu    = "2"
          memory = "1024Mi"
        }
      }
    }
  }
}
