#!/bin/bash

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SOURCE_FILE="$SCRIPT_DIR/rules/default.rules"
TARGET_DIR="$HOME/.codex/rules"
TARGET_FILE="$TARGET_DIR/default.rules"
BACKUP_FILE="$TARGET_FILE.backup"

if [ ! -f "$SOURCE_FILE" ]; then
  echo "rules file not found: $SOURCE_FILE" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

if [ -L "$TARGET_FILE" ] && [ "$(readlink "$TARGET_FILE")" = "$SOURCE_FILE" ]; then
  echo "already linked: $TARGET_FILE -> $SOURCE_FILE"
  exit 0
fi

if [ -e "$TARGET_FILE" ] || [ -L "$TARGET_FILE" ]; then
  if [ -e "$BACKUP_FILE" ] || [ -L "$BACKUP_FILE" ]; then
    echo "backup already exists: $BACKUP_FILE" >&2
    echo "remove or rename it before re-running." >&2
    exit 1
  fi

  mv "$TARGET_FILE" "$BACKUP_FILE"
  echo "backup: $TARGET_FILE -> $BACKUP_FILE"
fi

ln -s "$SOURCE_FILE" "$TARGET_FILE"
echo "linked: $TARGET_FILE -> $SOURCE_FILE"
