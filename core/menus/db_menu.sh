#!/usr/bin/env bash

db_menu() {
  local db="$1"
  PS3="Choose an option for database [$db]: "

  select choice in \
    "Create Table" \
    "List Tables" \
    "Drop Table" \
    "Insert Into Table" \
    "Select From Table" \
    "Delete From Table" \
    "Update Table" \
    "Back"
  do
    tput reset  # Clear the screen before each new menu

    case "$REPLY" in
      1) create_table "$db" ;;
      2) list_tables "$db" ;;
      3) drop_table "$db" ;;
      4) insert_into_table "$db" ;;
      5) select_from_table "$db" ;;
      6) delete_from_table "$db" ;;
      7) update_table "$db" ;;
      8) break ;;
      *) echo "Invalid choice" ;;
    esac
    pause  # Pause to allow user to see the result
  done
}
