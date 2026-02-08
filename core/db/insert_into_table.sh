#!/usr/bin/env bash

insert_into_table() {
  local db="$1"

  read -r -p "Enter table name: " table
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

  # Read table schema
  read_meta "$meta_file"

  local -a row=()
  local value

  for i in "${!cols[@]}"; do
    while true; do
      read -r -p "Enter ${cols[$i]} (${types[$i]}): " value

      # Primary key cannot be empty
      if [[ "$i" -eq "$pkIndex" && -z "$value" ]]; then
        echo "Primary key cannot be empty"
        continue
      fi

      # Check datatype (if value is not empty)
      if [[ -n "$value" ]]; then
        if ! check_value_type "${types[$i]}" "$value"; then
          echo "Invalid value type"
          continue
        fi
      fi

      # Check primary key uniqueness
      if [[ "$i" -eq "$pkIndex" ]]; then
        if pk_exists "$data_file" "$pkIndex" "$value"; then
          echo "Primary key value already exists"
          continue
        fi
      fi

      row+=("$value")
      break
    done
  done

  # Join row values with delimiter and append to data file
  local line
  line="$(IFS="$DELIM"; echo "${row[*]}")"
  echo "$line" >> "$data_file"

  echo "Row inserted successfully"
}
