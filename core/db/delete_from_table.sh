#!/usr/bin/env bash

delete_from_table() {
  local db="$1"

  read -r -p "Enter table name to delete from: " table
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
    read -r -p "Enter primary key to delete (${cols[$pkIndex]}): " pkval
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

  local tmp_file
  tmp_file="$(mktemp)"

  awk -F"$DELIM" -v idx="$((pkIndex + 1))" -v val="$pkval" '
    ($idx != val) { print }
  ' "$data_file" > "$tmp_file"

  mv "$tmp_file" "$data_file"

  echo "Record deleted successfully"
}
