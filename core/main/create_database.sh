#!/usr/bin/env bash

create_database() {
  read -r -p "Enter database name: " db

  # normalize name (replace spaces with underscore)
  db="$(normalize_name "$db")"

  # validate name
  if ! valid_name "$db"; then
    echo "Invalid database name"
    return
  fi

  # check if database already exists
  if db_exists "$db"; then
    echo "Database already exists"
    return
  fi

  # create database directory and meta folder
  mkdir -p "$(db_path "$db")/meta"

  echo "Database '$db' created successfully"
}
