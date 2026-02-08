#!/usr/bin/env bash

list_tables() {
  local db="$1"
  local mdir
  mdir="$(meta_dir "$db")"

  if [ ! -d "$mdir" ] || [ -z "$(ls -A "$mdir" 2>/dev/null)" ]; then
    echo "No tables found in database '$db'"
    return
  fi

  echo "Tables in database '$db':"
  for f in "$mdir"/*.meta; do
    [ -e "$f" ] || continue
    basename "$f" .meta
  done
}
