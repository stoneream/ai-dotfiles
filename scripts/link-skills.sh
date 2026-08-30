#!/bin/bash

set -eu

usage() {
  echo "Usage: $0 [--dry-run]" >&2
}

DRY_RUN=0

case "${1:-}" in
  "")
    ;;
  --dry-run)
    DRY_RUN=1
    ;;
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
SOURCE_ROOT="$REPO_ROOT/skills"
TARGET_HOME=${LINK_SKILLS_HOME:-"$HOME"}
TARGET_DIRS=(
  "$TARGET_HOME/.agents/skills"
  "$TARGET_HOME/.codex/skills"
  "$TARGET_HOME/.claude/skills"
)
SOURCE_DIRS=()
has_invalid_sources=0

for source_dir in "$SOURCE_ROOT"/*; do
  [ -d "$source_dir" ] || continue

  if [ ! -f "$source_dir/SKILL.md" ]; then
    echo "ignoring directory without SKILL.md: $source_dir" >&2
    continue
  fi

  skill_name=$(basename -- "$source_dir")
  declared_name=$(sed -n 's/^name:[[:space:]]*//p' "$source_dir/SKILL.md" | head -n 1)
  declared_name=${declared_name#\"}
  declared_name=${declared_name%\"}
  declared_name=${declared_name#\'}
  declared_name=${declared_name%\'}

  if [ "$declared_name" != "$skill_name" ]; then
    echo "skill name does not match directory: $source_dir (name: ${declared_name:-missing})" >&2
    has_invalid_sources=1
    continue
  fi

  SOURCE_DIRS+=("$source_dir")
done

if [ "$has_invalid_sources" -ne 0 ]; then
  exit 1
fi

if [ "${#SOURCE_DIRS[@]}" -eq 0 ]; then
  echo "no skill directories found: $SOURCE_ROOT" >&2
  exit 1
fi

path_exists() {
  [ -e "$1" ] || [ -L "$1" ]
}

is_expected_link() {
  local target_path=$1
  local source_dir=$2

  [ -L "$target_path" ] || return 1
  [ "$(readlink "$target_path")" = "$source_dir" ]
}

is_stale_managed_skill_link() {
  local target_path=$1
  local link_target
  local link_parent

  [ -L "$target_path" ] || return 1

  link_target=$(readlink "$target_path")
  link_parent=${link_target%/*}

  # Only direct children of SOURCE_ROOT are links managed by this script.
  [ "$link_parent" = "$SOURCE_ROOT" ] && {
    [ ! -d "$link_target" ] || [ ! -f "$link_target/SKILL.md" ]
  }
}

validate_target_dir() {
  local target_dir=$1
  local source_dir
  local skill_name
  local target_path
  local has_conflicts=0

  if path_exists "$target_dir" && [ ! -d "$target_dir" ]; then
    echo "target directory is not a directory: $target_dir" >&2
    return 1
  fi

  for source_dir in "${SOURCE_DIRS[@]}"; do
    skill_name=$(basename -- "$source_dir")
    target_path="$target_dir/$skill_name"

    if is_expected_link "$target_path" "$source_dir"; then
      continue
    fi

    if path_exists "$target_path"; then
      if ! is_stale_managed_skill_link "$target_path"; then
        echo "target already exists and points elsewhere: $target_path" >&2
        has_conflicts=1
      fi
    fi
  done

  [ "$has_conflicts" -eq 0 ]
}

remove_stale_links() {
  local target_dir=$1
  local target_path
  local link_target

  [ -d "$target_dir" ] || return 0

  while IFS= read -r -d '' target_path; do
    if is_stale_managed_skill_link "$target_path"; then
      link_target=$(readlink "$target_path")
      if [ "$DRY_RUN" -eq 1 ]; then
        echo "would remove stale link: $target_path -> $link_target"
      else
        rm "$target_path"
        echo "removed stale link: $target_path -> $link_target"
      fi
    fi
  done < <(find -H "$target_dir" -mindepth 1 -maxdepth 1 -type l -print0)
}

sync_target_dir() {
  local target_dir=$1
  local source_dir
  local skill_name
  local target_path

  if [ ! -d "$target_dir" ]; then
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "would create directory: $target_dir"
    else
      mkdir -p "$target_dir"
      echo "created directory: $target_dir"
    fi
  fi

  remove_stale_links "$target_dir"

  for source_dir in "${SOURCE_DIRS[@]}"; do
    skill_name=$(basename -- "$source_dir")
    target_path="$target_dir/$skill_name"

    if is_expected_link "$target_path" "$source_dir"; then
      echo "already linked: $target_path -> $source_dir"
    elif [ "$DRY_RUN" -eq 1 ]; then
      echo "would link: $target_path -> $source_dir"
    else
      ln -s "$source_dir" "$target_path"
      echo "linked: $target_path -> $source_dir"
    fi
  done
}

# Check every destination before changing anything to avoid partial updates.
has_conflicts=0

for target_dir in "${TARGET_DIRS[@]}"; do
  if ! validate_target_dir "$target_dir"; then
    has_conflicts=1
  fi
done

if [ "$has_conflicts" -ne 0 ]; then
  exit 1
fi

for target_dir in "${TARGET_DIRS[@]}"; do
  sync_target_dir "$target_dir"
done
