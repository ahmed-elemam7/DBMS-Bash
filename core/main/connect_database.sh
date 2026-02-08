#!/usr/bin/env bash

connect_database() {
  read -r -p "Enter database name: " db

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

  # open database menu
  db_menu "$db"
}
