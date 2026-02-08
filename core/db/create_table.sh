#!/usr/bin/env bash

create_table() {
  local db="$1"
  local table cols_count

  # Ask table name until valid (or q to cancel)
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

    if table_exists "$db" "$table"; then
      echo "Table already exists. Try another name."
      continue
    fi
    break
  done

  # Ask columns count until valid
  while true; do
    read -r -p "Enter number of columns: " cols_count
    if [[ "$cols_count" =~ ^[1-9][0-9]*$ ]]; then
      break
    fi
    echo "Invalid number. Try again."
  done

  mkdir -p "$(meta_dir "$db")"

  local meta_file data_file
  meta_file="$(table_meta "$db" "$table")"
  data_file="$(table_data "$db" "$table")"

  : > "$meta_file"
  : > "$data_file"

  local pk_chosen=0
  local i col dtype ans pkflag

  for ((i=1; i<=cols_count; i++)); do
    # Ask column name until valid and not duplicate
    while true; do
      read -r -p "Column $i name: " col
      col="$(normalize_name "$col")"

      if ! valid_name "$col"; then
        echo "Invalid column name. Try again."
        continue
      fi

      if grep -q "^${col}:" "$meta_file" 2>/dev/null; then
        echo "Duplicate column name. Try again."
        continue
      fi
      break
    done

    # Ask datatype until valid
    while true; do
      read -r -p "Datatype for $col (int|string|float): " dtype
      if is_valid_type "$dtype"; then
        break
      fi
      echo "Invalid datatype. Try again."
    done

    # Ask PK choice until valid
    while true; do
      read -r -p "Is '$col' Primary Key? (y/n): " ans
      case "$ans" in
        y|Y)
          if [[ "$pk_chosen" -eq 1 ]]; then
            echo "Primary key already chosen. Only one PK is allowed."
            continue
          fi
          pkflag=1
          pk_chosen=1
          break
          ;;
        n|N)
          pkflag=0
          break
          ;;
        *)
          echo "Please enter y or n."
          ;;
      esac
    done

    echo "${col}:${dtype}:${pkflag}" >> "$meta_file"
  done

  if [[ "$pk_chosen" -ne 1 ]]; then
    echo "You must choose exactly one primary key. Table creation cancelled."
    rm -f "$meta_file" "$data_file"
    return
  fi

  echo "Table '$table' created successfully in database '$db'"
}
