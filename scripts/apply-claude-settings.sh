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
TARGET_HOME=${APPLY_CLAUDE_HOME:-"$HOME"}
TARGET_PATH="$TARGET_HOME/.claude/settings.json"

if [ ! -f "$SOURCE_PATH" ]; then
  echo "source file not found: $SOURCE_PATH" >&2
  exit 1
fi

if [ ! -f "$TARGET_PATH" ]; then
  echo "target file not found: $TARGET_PATH" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not found" >&2
  exit 1
fi

merged=$(jq --slurpfile src "$SOURCE_PATH" \
  '($src[0].permissions.allow // []) as $new_allow
   | [.permissions.allow[]? | select(startswith("mcp__"))] as $mcp_allow
   | .permissions = $src[0].permissions
   | .permissions.allow = ($new_allow + $mcp_allow | unique)
   | .hooks = $src[0].hooks
   | .sandbox = $src[0].sandbox' \
  "$TARGET_PATH")

if [ "$(jq -S . "$TARGET_PATH")" = "$(echo "$merged" | jq -S .)" ]; then
  echo "already up to date: $TARGET_PATH"
  exit 0
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo "would update: $TARGET_PATH"
  echo "$merged" | jq .
else
  echo "$merged" | jq . > "$TARGET_PATH"
  echo "updated: $TARGET_PATH"
fi
