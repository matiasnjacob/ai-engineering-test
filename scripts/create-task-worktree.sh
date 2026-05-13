#!/usr/bin/env bash
set -euo pipefail

PROJECTS_ROOT="${AGENTIC_PROJECTS_ROOT:-/Users/matiasbinagora/Projects}"
WORKTREES_ROOT="${AGENTIC_WORKTREES_ROOT:-${PROJECTS_ROOT}/.worktrees}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
LINK_PROJECT_SCRIPT="${SCRIPT_DIR}/link-project.sh"

usage() {
  printf 'Usage:\n'
  printf '  %s <repo-path> <task-id> <kebab-task-name> [base-branch]\n' "$0"
  printf '\n'
  printf 'Example:\n'
  printf '  %s . FEATURE-006 notes-search-endpoint main\n' "$0"
}

canonical_dir() {
  local path="$1"
  if [ ! -d "$path" ]; then
    return 1
  fi
  (cd "$path" && pwd -P)
}

derive_task_number() {
  local task_id="$1"
  if [[ "$task_id" =~ ([0-9]+)$ ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
    return 0
  fi
  printf 'Task ID must end with a numeric suffix: %s\n' "$task_id" >&2
  return 1
}

ensure_kebab_name() {
  local name="$1"
  if [[ ! "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    printf 'Task name must be kebab-case: %s\n' "$name" >&2
    return 1
  fi
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

ensure_git_repo() {
  local repo="$1"
  if ! git -C "$repo" rev-parse --show-toplevel >/dev/null 2>&1; then
    printf 'Not a Git repository: %s\n' "$repo" >&2
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

  if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
    usage >&2
    exit 2
  fi

  local repo_input="$1"
  local task_id="$2"
  local task_name="$3"
  local base_branch="${4:-main}"
  local repo repo_root repo_name task_number branch worktrees_root_real worktree_path base_ref

  ensure_kebab_name "$task_name"
  task_number="$(derive_task_number "$task_id")"

  repo="$(canonical_dir "$repo_input")"
  ensure_repo_allowed "$repo"
  ensure_git_repo "$repo"
  repo_root="$(git -C "$repo" rev-parse --show-toplevel)"
  repo_root="$(canonical_dir "$repo_root")"
  repo_name="$(basename "$repo_root")"

  mkdir -p "$WORKTREES_ROOT"
  worktrees_root_real="$(canonical_dir "$WORKTREES_ROOT")"
  branch="feature/task-${task_number}-${task_name}"
  worktree_path="${worktrees_root_real}/${repo_name}/task-${task_number}-${task_name}"

  mkdir -p "$(dirname "$worktree_path")"

  if [ -e "$worktree_path" ] && ! worktree_registered "$repo_root" "$worktree_path"; then
    printf 'Target path exists but is not this repo worktree: %s\n' "$worktree_path" >&2
    exit 1
  fi

  if worktree_registered "$repo_root" "$worktree_path"; then
    printf 'Worktree already exists.\n'
  else
    if git -C "$repo_root" show-ref --verify --quiet "refs/heads/${branch}"; then
      git -C "$repo_root" worktree add "$worktree_path" "$branch"
    else
      if git -C "$repo_root" remote get-url origin >/dev/null 2>&1; then
        git -C "$repo_root" fetch origin "$base_branch" >/dev/null 2>&1 || true
      fi
      base_ref="$(resolve_base_ref "$repo_root" "$base_branch")"
      git -C "$repo_root" worktree add -b "$branch" "$worktree_path" "$base_ref"
    fi
  fi

  "$LINK_PROJECT_SCRIPT" "$worktree_path" >/dev/null

  printf 'Task ID: %s\n' "$task_id"
  printf 'Branch: %s\n' "$branch"
  printf 'Worktree: %s\n' "$worktree_path"
}

main "$@"
