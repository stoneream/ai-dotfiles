#!/bin/bash

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TEMPLATE_FILE="$SCRIPT_DIR/config.toml.template"
OUTPUT_FILE="$SCRIPT_DIR/config.toml"

# backup
cp ~/.codex/config.toml ./codex-config/backup-config.toml

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "template file not found: $TEMPLATE_FILE" >&2
  exit 1
fi

sed "s|HOME_DIR_PATH|$HOME|g" "$TEMPLATE_FILE" >"$OUTPUT_FILE"

echo "generated: $OUTPUT_FILE"
