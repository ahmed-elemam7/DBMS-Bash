#!/usr/bin/env bash

update_table() {
  local db="$1"

  read -r -p "Enter table name to update: " table
  table="$(normalize_name "$table")"

  if ! valid_name "$table"; then
    echo "Invalid table name"
    return
  fi

  if ! table_exists "$db" "$table"; then
    echo "Table does not exist"
    return
  fi

  local meta_file data_file
  meta_file="$(table_meta "$db" "$table")"
  data_file="$(table_data "$db" "$table")"

  read_meta "$meta_file"

  while true; do
    read -r -p "Enter primary key to update (${cols[$pkIndex]}): " pkval
    if [ -z "$pkval" ]; then
      echo "Primary key value is required"
      continue
    fi

    if ! pk_exists "$data_file" "$pkIndex" "$pkval"; then
      echo "No record found with this primary key"
      continue
    fi
    break
  done

  echo "Enter new values (leave empty to keep the old value)."

  local -a updates=()
  local value

  for i in "${!cols[@]}"; do
    if [[ "$i" -eq "$pkIndex" ]]; then
      updates+=("")  # Do not update PK (simpler)
      continue
    fi

    while true; do
      read -r -p "New ${cols[$i]} (${types[$i]}): " value

      if [ -z "$value" ]; then
        updates+=("")  # keep old
        break
      fi

      if ! check_value_type "${types[$i]}" "$value"; then
        echo "Invalid value type"
        continue
      fi

      updates+=("$value")
      break
    done
  done

  local tmp_file
  tmp_file="$(mktemp)"

  awk -F"$DELIM" -v OFS="$DELIM" \
    -v pkcol="$((pkIndex + 1))" -v pk="$pkval" \
    -v n="${#cols[@]}" \
    -v upd="$(IFS=$'\t'; echo "${updates[*]}")" '
    BEGIN { split(upd, u, "\t") }
    {
      if ($pkcol == pk) {
        for (i = 1; i <= n; i++) {
          if (i != pkcol && u[i-1] != "") {
            $i = u[i-1]
          }
        }
      }
      print
    }
  ' "$data_file" > "$tmp_file"

  mv "$tmp_file" "$data_file"

  echo "Record updated successfully"
}
