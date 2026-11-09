#!/bin/bash

set -eu

usage() {
  echo "Usage: $0 [--dry-run]" >&2
}

DRY_RUN=0

case "${1:-}" in
  "") ;;
  --dry-run) DRY_RUN=1 ;;
  *)
    usage
    exit 2
    ;;
esac

if [ "$#" -gt 1 ]; then
  usage
  exit 2
fi

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd)
SOURCE_PATH="$REPO_ROOT/.claude/settings.json"
TARGET_HOME=${LINK_CLAUDE_HOME:-"$HOME"}
TARGET_DIR="$TARGET_HOME/.claude"
TARGET_PATH="$TARGET_DIR/settings.json"

if [ ! -f "$SOURCE_PATH" ]; then
  echo "source file not found: $SOURCE_PATH" >&2
  exit 1
fi

if { [ -e "$TARGET_DIR" ] || [ -L "$TARGET_DIR" ]; } && [ ! -d "$TARGET_DIR" ]; then
  echo "target directory is not a directory: $TARGET_DIR" >&2
  exit 1
fi

if [ -L "$TARGET_PATH" ] && [ "$(readlink "$TARGET_PATH")" = "$SOURCE_PATH" ]; then
  echo "already linked: $TARGET_PATH -> $SOURCE_PATH"
  exit 0
fi

if [ -e "$TARGET_PATH" ] || [ -L "$TARGET_PATH" ]; then
  echo "target already exists and points elsewhere: $TARGET_PATH" >&2
  exit 1
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo "would link: $TARGET_PATH -> $SOURCE_PATH"
else
  mkdir -p "$TARGET_DIR"
  ln -s "$SOURCE_PATH" "$TARGET_PATH"
  echo "linked: $TARGET_PATH -> $SOURCE_PATH"
fi
