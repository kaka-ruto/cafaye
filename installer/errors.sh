#!/bin/bash
# Cafaye OS: Error Handling Helpers

ERROR_HANDLING=false

show_cursor() {
  printf "\033[?25h"
}

hide_cursor() {
  printf "\033[?25l"
}

# Display error and offer options
catch_errors() {
  if [[ $ERROR_HANDLING == true ]]; then
    return
  else
    ERROR_HANDLING=true
  fi

  local exit_code=$?
  restore_outputs
  hide_cursor

  echo ""
  gum style --foreground 1 --padding "1 2" "Cafaye installation stopped!"
  echo ""
  gum style "Exit code: $exit_code"
  echo ""
  gum style "Check logs at: $CAFAYE_INSTALL_LOG"
  echo ""

  while true; do
    choice=$(gum choose \
      "Retry installation" \
      "View log" \
      "Exit" \
      --header "What would you like to do?")

    case "$choice" in
      "Retry installation")
        bash "$0" "$@"
        break
        ;;
      "View log")
        if command -v less &>/dev/null; then
          less "$CAFAYE_INSTALL_LOG"
        else
          tail "$CAFAYE_INSTALL_LOG"
        fi
        ;;
      "Exit" | "")
        exit 1
        ;;
    esac
  done
}

exit_handler() {
  local exit_code=$?
  if [[ $exit_code -ne 0 && $ERROR_HANDLING != true ]]; then
    catch_errors
  fi
  show_cursor
}

trap catch_errors ERR INT TERM
trap exit_handler EXIT
