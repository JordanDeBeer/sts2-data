jq '.map_point_history |= (to_entries | map({act: (.key + 1), points: .value}))' ./data/*.run
