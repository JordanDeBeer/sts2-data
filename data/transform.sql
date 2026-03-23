SELECT
  off + 1 AS act,
  point AS points
FROM `project.dataset.landing_table`,
UNNEST(map_point_history) AS point WITH OFFSET off

/*
gcsRef := bigquery.NewGCSReference("gs://my-bucket/runs/file.json")
gcsRef.SourceFormat = bigquery.JSON
loader := client.Dataset("my_dataset").Table("staging_table").LoaderFrom(gcsRef)
job, _ := loader.Run(ctx)
*/
