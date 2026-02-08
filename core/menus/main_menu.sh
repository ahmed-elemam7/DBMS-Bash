#!/usr/bin/env bash
main_menu() {
  PS3="Choose an option form main menu: "

  select choice in \
    "Create Database" \
    "List Databases" \
    "Connect To Database" \
    "Drop Database" \
    "Exit"
  do
    tput reset  # Clear the screen before each new menu

    case "$REPLY" in
      1) create_database ;;
      2) list_databases ;;
      3) connect_database ;;
      4) drop_database ;;
      5) exit 0 ;;
      *) echo "Invalid choice" ;;
    esac

    pause  # Pause after action so the user can see the output
  done
}
