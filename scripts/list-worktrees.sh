#!/usr/bin/env bash
set -euo pipefail

PROJECTS_ROOT="${AGENTIC_PROJECTS_ROOT:-/Users/matiasbinagora/Projects}"

usage() {
  printf 'Usage:\n'
  printf '  %s [repo-path]\n' "$0"
}

canonical_dir() {
  local path="$1"
  if [ ! -d "$path" ]; then
    return 1
  fi
  (cd "$path" && pwd -P)
}

main() {
  if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    usage
    exit 0
  fi

  if [ "$#" -gt 1 ]; then
    usage >&2
    exit 2
  fi

  local repo repo_root projects_root_real
  repo="$(canonical_dir "${1:-.}")"
  projects_root_real="$(canonical_dir "$PROJECTS_ROOT")"

  case "${repo}/" in
    "${projects_root_real}/"*) ;;
    *)
      printf 'Repository is outside %s: %s\n' "$projects_root_real" "$repo" >&2
      exit 1
      ;;
  esac

  if ! git -C "$repo" rev-parse --show-toplevel >/dev/null 2>&1; then
    printf 'Not a Git repository: %s\n' "$repo" >&2
    exit 1
  fi

  repo_root="$(git -C "$repo" rev-parse --show-toplevel)"
  printf 'Repository: %s\n' "$repo_root"
  git -C "$repo_root" worktree list
}

main "$@"
