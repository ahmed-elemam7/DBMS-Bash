#!/usr/bin/env bash

select_from_table() {
  local db="$1"
  local table meta_file data_file

  while true; do
    read -r -p "Enter table name (or q to cancel): " table
    table="$(normalize_name "$table")"

    if [[ "$table" == "q" ]]; then
      echo "Cancelled"
      return
    fi

    if ! valid_name "$table"; then
      echo "Invalid table name. Try again."
      continue
    fi

    if ! table_exists "$db" "$table"; then
      echo "Table does not exist. Try again."
      continue
    fi

    break
  done

  meta_file="$(table_meta "$db" "$table")"
  data_file="$(table_data "$db" "$table")"
  read_meta "$meta_file"

  PS3="Select option: "
  select choice in "Select All" "Select By Primary Key" "Back"
  do
    case "$REPLY" in
      1)
        if [ ! -s "$data_file" ]; then
          echo "Table is empty"
        else
          print_table "$meta_file" "$data_file"
        fi
        ;;
      2)
        while true; do
          read -r -p "Enter primary key value (${cols[$pkIndex]}): " pkval
          if [ -z "$pkval" ]; then
            echo "Primary key value is required"
            continue
          fi

          tmp_file="$(mktemp)"
          awk -F"$DELIM" -v idx="$((pkIndex + 1))" -v val="$pkval" '($idx==val){print}' "$data_file" > "$tmp_file"

          if [ ! -s "$tmp_file" ]; then
            echo "No matching record"
          else
            print_table "$meta_file" "$tmp_file"
          fi

          rm -f "$tmp_file"
          break
        done
        ;;
      3) break ;;
      *) echo "Invalid choice" ;;
    esac
  done
}

