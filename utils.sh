#!/bin/bash

GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BLUE="\033[1;34m"
NC="\033[0m"

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
      exit 1
  esac

  echo -e "[$color $level $NC] - ${date +'%T %D'} $message"
}

check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}
