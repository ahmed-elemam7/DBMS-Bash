#!/usr/bin/env bash

# Check if datatype is supported
# Supported types: int, string, float
is_valid_type() {
  case "$1" in
    int|string|float) return 0 ;;
    *) return 1 ;;
  esac
}

# Validate value against its datatype
check_value_type() {
  local type="$1"
  local value="$2"

  case "$type" in
    int)
      [[ "$value" =~ ^-?[0-9]+$ ]]
      ;;
    float)
      [[ "$value" =~ ^-?[0-9]+([.][0-9]+)?$ ]]
      ;;
    string)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# Read table meta file
# Meta format: column:type:pkFlag
# Fills arrays: cols[], types[]
# Sets pkIndex (0-based)
read_meta() {
  local meta_file="$1"

  cols=()
  types=()
  pkIndex=-1

  local i=0
  while IFS=: read -r col type pk; do
    cols+=("$col")
    types+=("$type")

    if [[ "$pk" == "1" ]]; then
      pkIndex="$i"
    fi

    ((i++))
  done < "$meta_file"
}

# Check if primary key value already exists in data file
# pkIndex is 0-based
pk_exists() {
  local data_file="$1"
  local pkIndex="$2"
  local pkValue="$3"

  awk -F"$DELIM" -v idx="$((pkIndex + 1))" -v val="$pkValue" '
    ($idx == val) { found = 1 }
    END { exit(found ? 0 : 1) }
  ' "$data_file"
}
