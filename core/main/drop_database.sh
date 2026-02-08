#!/usr/bin/env bash

drop_database() {
  read -r -p "Enter database name to drop: " db

  # normalize name (replace spaces with underscore)
  db="$(normalize_name "$db")"

  # validate name
  if ! valid_name "$db"; then
    echo "Invalid database name"
    return
  fi

  # check if database exists
  if ! db_exists "$db"; then
    echo "Database does not exist"
    return
  fi

  # confirmation
  read -r -p "Are you sure you want to delete '$db'? (y/n): " confirm
  case "$confirm" in
    y|Y)
      rm -rf "$(db_path "$db")"
      echo "Database '$db' deleted successfully"
      ;;
    *)
      echo "Operation cancelled"
      ;;
  esac
}
