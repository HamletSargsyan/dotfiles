#!/bin/bash

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color


log() {
  local level=$1
  local message=$2
  local color

  case "$level" in
    "info")
      color=$BLUE
      ;;
    "warning")
      color=$YELLOW
      ;;
    "error")
      color=$RED
      ;;
    "success")
      color=$GREEN
      ;;
    *)
      echo -e "${RED}Unknown level: $level${NC}"
      return 1
      ;;
  esac

  echo -e "$color [ $level ] - $(date +'%T') - $message$NC"
}

check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

run_command() {
  local cmd=$1
  if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY RUN]${NC} $cmd"
    sleep 0.5
  fi

  eval "${cmd}"
  local exit_code=$?

  if [ $exit_code -ne 0 ]; then
    log "error" "Failed to run command: ${cmd}"
  fi

  return $exit_code
}
