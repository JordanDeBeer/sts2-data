SELECT
  off + 1 AS act,
  point AS points
FROM `project.dataset.landing_table`,
UNNEST(map_point_history) AS point WITH OFFSET off
