#!/usr/bin/env bash

# Pause execution until user presses Enter
pause() {
  read -r -p "Press Enter to continue..." _
}

# Normalize names by replacing spaces with underscore
# Example: "student data" -> "student_data"
normalize_name() {
  echo "$1" | tr ' ' '_'
}

# Validate names (database / table / column)
# Must start with a letter or underscore
# Can contain letters, numbers, and underscores only
valid_name() {
  [[ "$1" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]
}

# Return database directory path
db_path() {
  echo "$DATA_DIR/$1"
}

# Return meta directory path
meta_dir() {
  echo "$(db_path "$1")/meta"
}

# Return table data file path
table_data() {
  echo "$(db_path "$1")/$2.data"
}

# Return table meta file path
table_meta() {
  echo "$(meta_dir "$1")/$2.meta"
}

# Check if database exists
db_exists() {
  [[ -d "$(db_path "$1")" ]]
}

# Check if table exists (both meta and data files)
table_exists() {
  [[ -f "$(table_meta "$1" "$2")" && -f "$(table_data "$1" "$2")" ]]
}

# Print table data in a simple formatted way
print_table() {
  local meta_file="$1"
  local data_file="$2"

  # Print header
  awk -F: '{ printf "%-15s", $1 } END { print "" }' "$meta_file"
  awk -F: '{ printf "%-15s", "--------------" } END { print "" }' "$meta_file"

  # Print rows
  awk -F"$DELIM" '{
    for (i = 1; i <= NF; i++) {
      printf "%-15s", $i
    }
    print ""
  }' "$data_file"
}
