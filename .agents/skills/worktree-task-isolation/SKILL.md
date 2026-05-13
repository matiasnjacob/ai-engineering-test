---
name: worktree-task-isolation
description: Use when starting implementation, review, or functional validation work that needs isolated Git branches or concurrent task execution with Git worktrees.
---

# Worktree Task Isolation

Use this skill whenever an agent creates, checks out, validates, or cleans up task-specific Git worktrees.

## Core Rules

- Use one Git worktree per active implementation task by default.
- Worktrees are mandatory when more than one active task exists for the same repository.
- Developer worktrees live under `/Users/matiasbinagora/Projects/.worktrees/<repo>/task-{number}-{kebab-case-name}`.
- Review worktrees live under `/Users/matiasbinagora/Projects/.worktrees/<repo>/review-pr-{number}`.
- Do not edit implementation files in the original project root once a task worktree exists.
- Report the worktree path and branch in every implementation, code review, or functional review output when local checkout is used.
- Remove worktrees only after the task is Done or when cleanup is explicitly requested.
- Do not delete branches unless explicitly requested.

## Scripts

- Create task worktree: `/Users/matiasbinagora/Projects/_agentic-programming/scripts/create-task-worktree.sh <repo-path> <task-id> <kebab-task-name> [base-branch]`
- Create review worktree: `/Users/matiasbinagora/Projects/_agentic-programming/scripts/create-review-worktree.sh <repo-path> <pr-number> [base-branch]`
- List worktrees: `/Users/matiasbinagora/Projects/_agentic-programming/scripts/list-worktrees.sh [repo-path]`
- Remove worktree: `/Users/matiasbinagora/Projects/_agentic-programming/scripts/remove-task-worktree.sh <worktree-path> [--force] [--delete-branch]`

## Required References

- Read `references/worktree-workflow.md` for full lifecycle rules.
- Use `github-pr-workflow` for branch, commit, push, and PR rules.

## Output

Include worktree path and branch whenever a worktree is created or used.
