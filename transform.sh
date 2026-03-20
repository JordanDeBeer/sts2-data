#jq '.map_point_history |= (to_entries | map({("act_" + (.key + 1 | tostring)): .value}) | add)' $1

jq '.map_point_history |= (to_entries | map({act: (.key + 1), points: .value}))' ./data/*.run
