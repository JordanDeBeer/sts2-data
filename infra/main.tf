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

resource "google_storage_bucket" "bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
}
resource "google_storage_bucket_iam_member" "bucket_reader" {
  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.api_sa.email}"
}

resource "google_bigquery_dataset_iam_member" "member" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  role       = "roles/bigquery.dataOwner"
  member     = "serviceAccount:${google_service_account.api_sa.email}"
}

resource "google_project_iam_member" "pipeline_binding" {
  project = var.project_id
  role    = "roles/bigquery.user"
  member  = "serviceAccount:${google_service_account.api_sa.email}"
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id    = var.dataset_id
  friendly_name = "STS2 Dataset"
  description   = "Dataset for STS2 data"
  location      = var.region

  depends_on = [google_project_service.bigquery]
}

resource "google_bigquery_table" "table" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "runs"

  schema = file("${path.module}/../data/table_schema.json")

  deletion_protection = false # Set to true for production
}

resource "google_bigquery_table" "table-raw" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "runs-raw"

  deletion_protection = false # Set to true for production
}

resource "google_service_account" "api_sa" {
  account_id   = "api-service-account"
  display_name = "API Service Account"
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
      image = "us-central1-docker.pkg.dev/sts2-490800/sts2/api@sha256:81a52d785343fa470c3d71400347625b646c920e16eeb018916da2cbb5428250"
      env {
        name  = "BUCKET_NAME"
        value = google_storage_bucket.bucket.name
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
