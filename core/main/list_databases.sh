#!/usr/bin/env bash

list_databases() {
  if [ ! -d "$DATA_DIR" ] || [ -z "$(ls -A "$DATA_DIR" 2>/dev/null)" ]; then
    echo "No databases found"
    return
  fi

  echo "Available Databases:"
  ls -1 "$DATA_DIR"
}
