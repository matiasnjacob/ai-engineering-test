#!/usr/bin/env bash
set -euo pipefail

PROJECTS_ROOT="${AGENTIC_PROJECTS_ROOT:-/Users/matiasbinagora/Projects}"
WORKTREES_ROOT="${AGENTIC_WORKTREES_ROOT:-${PROJECTS_ROOT}/.worktrees}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
LINK_PROJECT_SCRIPT="${SCRIPT_DIR}/link-project.sh"

usage() {
  printf 'Usage:\n'
  printf '  %s <repo-path> <pr-number> [base-branch]\n' "$0"
  printf '\n'
  printf 'Creates a read-only review worktree for local PR validation.\n'
}

canonical_dir() {
  local path="$1"
  if [ ! -d "$path" ]; then
    return 1
  fi
  (cd "$path" && pwd -P)
}

ensure_repo_allowed() {
  local repo="$1"
  local projects_root_real
  projects_root_real="$(canonical_dir "$PROJECTS_ROOT")"
  case "${repo}/" in
    "${projects_root_real}/"*) ;;
    *)
      printf 'Repository is outside %s: %s\n' "$projects_root_real" "$repo" >&2
      return 1
      ;;
  esac
}

ensure_pr_number() {
  local pr_number="$1"
  if [[ ! "$pr_number" =~ ^[0-9]+$ ]]; then
    printf 'PR number must be numeric: %s\n' "$pr_number" >&2
    return 1
  fi
}

resolve_base_ref() {
  local repo="$1"
  local base_branch="$2"

  if git -C "$repo" show-ref --verify --quiet "refs/remotes/origin/${base_branch}"; then
    printf 'origin/%s\n' "$base_branch"
    return 0
  fi

  if git -C "$repo" show-ref --verify --quiet "refs/heads/${base_branch}"; then
    printf '%s\n' "$base_branch"
    return 0
  fi

  printf 'Base branch not found locally or on origin: %s\n' "$base_branch" >&2
  return 1
}

worktree_registered() {
  local repo="$1"
  local worktree_path="$2"
  git -C "$repo" worktree list --porcelain | grep -Fxq "worktree ${worktree_path}"
}

main() {
  if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    usage
    exit 0
  fi

  if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    usage >&2
    exit 2
  fi

  local repo_input="$1"
  local pr_number="$2"
  local base_branch="${3:-main}"
  local repo repo_root repo_name branch worktrees_root_real worktree_path base_ref

  ensure_pr_number "$pr_number"

  repo="$(canonical_dir "$repo_input")"
  ensure_repo_allowed "$repo"
  if ! git -C "$repo" rev-parse --show-toplevel >/dev/null 2>&1; then
    printf 'Not a Git repository: %s\n' "$repo" >&2
    exit 1
  fi

  repo_root="$(git -C "$repo" rev-parse --show-toplevel)"
  repo_root="$(canonical_dir "$repo_root")"
  repo_name="$(basename "$repo_root")"
  mkdir -p "$WORKTREES_ROOT"
  worktrees_root_real="$(canonical_dir "$WORKTREES_ROOT")"
  branch="review/pr-${pr_number}"
  worktree_path="${worktrees_root_real}/${repo_name}/review-pr-${pr_number}"

  mkdir -p "$(dirname "$worktree_path")"

  if [ -e "$worktree_path" ] && ! worktree_registered "$repo_root" "$worktree_path"; then
    printf 'Target path exists but is not this repo worktree: %s\n' "$worktree_path" >&2
    exit 1
  fi

  if worktree_registered "$repo_root" "$worktree_path"; then
    printf 'Review worktree already exists.\n'
  else
    if git -C "$repo_root" remote get-url origin >/dev/null 2>&1; then
      git -C "$repo_root" fetch origin "pull/${pr_number}/head:${branch}"
    elif git -C "$repo_root" show-ref --verify --quiet "refs/heads/${branch}"; then
      true
    else
      base_ref="$(resolve_base_ref "$repo_root" "$base_branch")"
      git -C "$repo_root" branch "$branch" "$base_ref"
      printf 'No origin remote found. Created %s from %s; manually checkout PR changes if needed.\n' "$branch" "$base_ref"
    fi

    git -C "$repo_root" worktree add "$worktree_path" "$branch"
  fi

  "$LINK_PROJECT_SCRIPT" "$worktree_path" >/dev/null

  printf 'PR: %s\n' "$pr_number"
  printf 'Branch: %s\n' "$branch"
  printf 'Worktree: %s\n' "$worktree_path"
}

main "$@"
