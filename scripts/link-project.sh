#!/usr/bin/env bash
set -euo pipefail

PROJECTS_ROOT="${AGENTIC_PROJECTS_ROOT:-/Users/matiasbinagora/Projects}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SHARED_ROOT="${AGENTIC_SHARED_ROOT:-$(cd "${SCRIPT_DIR}/.." && pwd -P)}"

ASSET_TARGETS=(
  "AGENTS.md"
  "Agent Exercise Prompts.md"
  "skills-lock.json"
  ".agents"
  ".opencode/agents"
  "docs/agents"
  "docs/workflows"
)

IGNORE_PATTERNS=(
  "/AGENTS.md"
  "/Agent Exercise Prompts.md"
  "/skills-lock.json"
  "/.agents"
  "/.opencode/agents"
  "/docs/agents"
  "/docs/workflows"
)

usage() {
  printf 'Usage:\n'
  printf '  %s [project-path]\n' "$0"
  printf '  %s --all\n' "$0"
  printf '\n'
  printf 'Links shared agentic-programming assets into projects under %s.\n' "$PROJECTS_ROOT"
}

canonical_dir() {
  local path="$1"
  if [ ! -d "$path" ]; then
    return 1
  fi
  (cd "$path" && pwd -P)
}

ensure_sources_exist() {
  local target source
  for target in "${ASSET_TARGETS[@]}"; do
    source="${SHARED_ROOT}/${target}"
    if [ ! -e "$source" ]; then
      printf 'Missing shared asset: %s\n' "$source" >&2
      return 1
    fi
  done
}

link_asset() {
  local project="$1"
  local target_rel="$2"
  local source="${SHARED_ROOT}/${target_rel}"
  local target="${project}/${target_rel}"
  local parent
  parent="$(dirname "$target")"

  if [ -L "$target" ]; then
    local existing
    existing="$(readlink "$target")"
    if [ "$existing" = "$source" ]; then
      printf '  ok: %s\n' "$target_rel"
    else
      printf '  conflict: %s is a symlink to %s\n' "$target_rel" "$existing"
    fi
    return 0
  fi

  if [ -e "$target" ]; then
    printf '  conflict: %s already exists\n' "$target_rel"
    return 0
  fi

  if [ ! -e "$parent" ] && [ ! -L "$parent" ]; then
    mkdir -p "$parent"
  fi

  if [ ! -d "$parent" ]; then
    printf '  conflict: parent for %s is not a directory\n' "$target_rel"
    return 0
  fi

  ln -s "$source" "$target"
  printf '  linked: %s\n' "$target_rel"
}

add_git_excludes() {
  local project="$1"

  if ! git -C "$project" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf '  note: not a Git repository; local excludes not updated\n'
    return 0
  fi

  local git_top
  git_top="$(git -C "$project" rev-parse --show-toplevel)"
  if [ "$git_top" != "$project" ]; then
    printf '  note: Git root is %s; skip excludes for nested project path\n' "$git_top"
    return 0
  fi

  local exclude_ref exclude_path pattern
  exclude_ref="$(git -C "$project" rev-parse --git-path info/exclude)"
  case "$exclude_ref" in
    /*) exclude_path="$exclude_ref" ;;
    *) exclude_path="${project}/${exclude_ref}" ;;
  esac

  mkdir -p "$(dirname "$exclude_path")"
  touch "$exclude_path"

  for pattern in "${IGNORE_PATTERNS[@]}"; do
    if ! grep -Fxq "$pattern" "$exclude_path"; then
      printf '%s\n' "$pattern" >> "$exclude_path"
      printf '  ignored: %s\n' "$pattern"
    fi
  done
}

link_project() {
  local input_path="$1"
  local project projects_root_real

  if ! project="$(canonical_dir "$input_path")"; then
    printf 'Skip: %s is not a directory\n' "$input_path"
    return 0
  fi

  projects_root_real="$(canonical_dir "$PROJECTS_ROOT")"
  case "${project}/" in
    "${projects_root_real}/"*) ;;
    *)
      printf 'Skip: %s is outside %s\n' "$project" "$projects_root_real"
      return 0
      ;;
  esac

  if [ "$project" = "$projects_root_real" ]; then
    printf 'Skip: %s is the projects root, not a project\n' "$project"
    return 0
  fi

  if [ "$project" = "$SHARED_ROOT" ]; then
    printf 'Skip: %s is the shared agentic-programming source\n' "$project"
    return 0
  fi

  printf 'Project: %s\n' "$project"
  local target_rel
  for target_rel in "${ASSET_TARGETS[@]}"; do
    link_asset "$project" "$target_rel"
  done
  add_git_excludes "$project"
}

main() {
  ensure_sources_exist

  if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    usage
    exit 0
  fi

  if [ "${1:-}" = "--all" ]; then
    local projects_root_real child
    projects_root_real="$(canonical_dir "$PROJECTS_ROOT")"
    for child in "${projects_root_real}"/*; do
      [ -d "$child" ] || continue
      link_project "$child"
    done
    return 0
  fi

  if [ "$#" -gt 1 ]; then
    usage >&2
    exit 2
  fi

  link_project "${1:-.}"
}

main "$@"
