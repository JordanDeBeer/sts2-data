variable "project_name" {
  description = "The name of the GCP project"
  type        = string
  default     = "sts2"
}

variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
  default     = "sts2-490800"
}

variable "region" {
  description = "The region to deploy resources in"
  type        = string
  default     = "us-central1"
}

variable "dataset_id" {
  description = "The ID of the BigQuery dataset"
  type        = string
  default     = "slaythespire2"
}

variable "bucket_name" {
  description = "The name of the GCS bucket"
  type        = string
  default     = "sts2-data"
}
