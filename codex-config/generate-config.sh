#!/bin/bash

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

DIST_DIR="$SCRIPT_DIR/dist"
BACKUP_DIR="$SCRIPT_DIR/backup"
CONFIG_TEMPLATE_FILE="$SCRIPT_DIR/config.toml.template"
CONFIG_OUTPUT_FILE="$DIST_DIR/config.toml"
HOOKS_TEMPLATE_FILE="$SCRIPT_DIR/hooks.json.template"
HOOKS_OUTPUT_FILE="$DIST_DIR/hooks.json"
BACKUP_CONFIG_FILE="$BACKUP_DIR/config.toml"
BACKUP_HOOKS_FILE="$BACKUP_DIR/hooks.json"
CODEX_CONFIG_FILE="$HOME/.codex/config.toml"
CODEX_HOOKS_FILE="$HOME/.codex/hooks.json"

mkdir -p "$DIST_DIR" "$BACKUP_DIR"

# backup
cp "$CODEX_CONFIG_FILE" "$BACKUP_CONFIG_FILE"
if [ -f "$CODEX_HOOKS_FILE" ]; then
  cp "$CODEX_HOOKS_FILE" "$BACKUP_HOOKS_FILE"
else
  printf '{\n  "hooks": {}\n}\n' >"$BACKUP_HOOKS_FILE"
fi

if [ ! -f "$CONFIG_TEMPLATE_FILE" ]; then
  echo "template file not found: $CONFIG_TEMPLATE_FILE" >&2
  exit 1
fi

if [ ! -f "$HOOKS_TEMPLATE_FILE" ]; then
  echo "template file not found: $HOOKS_TEMPLATE_FILE" >&2
  exit 1
fi

sed "s|HOME_DIR_PATH|$HOME|g" "$CONFIG_TEMPLATE_FILE" >"$CONFIG_OUTPUT_FILE"
sed "s|HOME_DIR_PATH|$HOME|g" "$HOOKS_TEMPLATE_FILE" >"$HOOKS_OUTPUT_FILE"

echo "generated: $CONFIG_OUTPUT_FILE"
echo "generated: $HOOKS_OUTPUT_FILE"
