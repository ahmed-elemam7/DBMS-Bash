#!/usr/bin/env bash

drop_table() {
  local db="$1"

  read -r -p "Enter table name to drop: " table
  table="$(normalize_name "$table")"

  if ! valid_name "$table"; then
    echo "Invalid table name"
    return
  fi

  if ! table_exists "$db" "$table"; then
    echo "Table does not exist"
    return
  fi

  read -r -p "Are you sure you want to delete table '$table'? (y/n): " confirm
  case "$confirm" in
    y|Y)
      rm -f "$(table_meta "$db" "$table")" "$(table_data "$db" "$table")"
      echo "Table '$table' deleted successfully"
      ;;
    *)
      echo "Operation cancelled"
      ;;
  esac
}
