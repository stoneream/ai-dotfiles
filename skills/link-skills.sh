#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
SOURCE_ROOT="$REPO_ROOT/skills"
DRY_RUN=0
TARGETS=(
  "${HOME}/.codex/skills"
  "${HOME}/.claude/skills"
)

print_command() {
  local escaped=()
  local arg

  for arg in "$@"; do
    printf -v arg '%q' "$arg"
    escaped+=("$arg")
  done

  printf '%s\n' "${escaped[*]}"
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [--dry-run]

Link each directory under $SOURCE_ROOT that contains SKILL.md into:
  ${HOME}/.codex/skills/<skill-name>
  ${HOME}/.claude/skills/<skill-name>
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -n|--dry-run)
      DRY_RUN=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      echo "unexpected argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [ ! -d "$SOURCE_ROOT" ]; then
  echo "source directory not found: $SOURCE_ROOT" >&2
  exit 1
fi

for TARGET_DIR in "${TARGETS[@]}"; do
  if [ "$DRY_RUN" -eq 1 ]; then
    print_command mkdir -p "$TARGET_DIR"
  else
    mkdir -p "$TARGET_DIR"
  fi

  linked_count=0
  skipped_count=0

  for skill_dir in "$SOURCE_ROOT"/*; do
    [ -d "$skill_dir" ] || continue
    [ -f "$skill_dir/SKILL.md" ] || continue

    skill_name=$(basename "$skill_dir")
    target_path="$TARGET_DIR/$skill_name"

    if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
      echo "skip: $target_path already exists and is not a symlink" >&2
      skipped_count=$((skipped_count + 1))
      continue
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
      print_command rm -f "$target_path"
      print_command ln -s "$skill_dir" "$target_path"
    else
      rm -f "$target_path"
      ln -s "$skill_dir" "$target_path"
      printf 'linked: %s -> %s\n' "$target_path" "$skill_dir"
    fi

    linked_count=$((linked_count + 1))
  done

  printf 'done: linked=%s skipped=%s target=%s\n' "$linked_count" "$skipped_count" "$TARGET_DIR"
done
