output "dataset_id" {
  value       = google_bigquery_dataset.dataset.dataset_id
  description = "The created BigQuery dataset ID"
}

output "table_id" {
  value       = google_bigquery_table.table.table_id
  description = "The created BigQuery table ID"
}
