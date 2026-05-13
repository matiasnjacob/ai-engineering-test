#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage:\n'
  printf '  %s <worktree-path> [--force] [--delete-branch]\n' "$0"
  printf '\n'
  printf 'Removes a clean worktree. Branch deletion is opt-in and uses safe git branch -d.\n'
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

  if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
    usage >&2
    exit 2
  fi

  local worktree_input="$1"
  local force="false"
  local delete_branch="false"
  shift

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --force) force="true" ;;
      --delete-branch) delete_branch="true" ;;
      *)
        printf 'Unknown option: %s\n' "$1" >&2
        usage >&2
        exit 2
        ;;
    esac
    shift
  done

  local worktree branch common_git status
  worktree="$(canonical_dir "$worktree_input")"

  if ! git -C "$worktree" rev-parse --show-toplevel >/dev/null 2>&1; then
    printf 'Not a Git worktree: %s\n' "$worktree" >&2
    exit 1
  fi

  if [ "$(git -C "$worktree" rev-parse --show-toplevel)" != "$worktree" ]; then
    printf 'Path is not the root of a worktree: %s\n' "$worktree" >&2
    exit 1
  fi

  branch="$(git -C "$worktree" branch --show-current)"
  common_git="$(git -C "$worktree" rev-parse --git-common-dir)"
  status="$(git -C "$worktree" status --short)"

  if [ -n "$status" ] && [ "$force" != "true" ]; then
    printf 'Refusing to remove dirty worktree: %s\n' "$worktree" >&2
    printf '%s\n' "$status" >&2
    exit 1
  fi

  if [ "$force" = "true" ]; then
    git -C "$worktree" worktree remove --force "$worktree"
  else
    git -C "$worktree" worktree remove "$worktree"
  fi

  if [ "$delete_branch" = "true" ] && [ -n "$branch" ]; then
    git --git-dir="$common_git" branch -d "$branch"
  fi

  printf 'Removed worktree: %s\n' "$worktree"
  if [ "$delete_branch" != "true" ] && [ -n "$branch" ]; then
    printf 'Branch kept: %s\n' "$branch"
  fi
}

main "$@"
