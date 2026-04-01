jq '.map_point_history |= (to_entries | map({act: (.key + 1), points: .value}))' ./data/*.run

gcloud storage cat gs://sts2-data/ace7a31179a4f0d5.run gs://sts2-data/31583c1e435d8989.run | jq '.map_point_history |= (to_entries | map({act: (.key + 1), points: .value}))' | gcloud storage cp gs://sts2-data/processed/
