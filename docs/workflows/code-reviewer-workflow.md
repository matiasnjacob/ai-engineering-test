# Code Reviewer Workflow

Lightweight index for technical pull request review.

## Required Skills

- `code-review-pr`
- `worktree-task-isolation`
- `github-pr-workflow`
- `trello-workflow-governance` when Trello is used

## Review Gate

Code Reviewer validates:

- PR scope
- branch naming
- architecture boundaries
- dependency direction
- code quality
- test quality
- validation evidence
- worktree isolation when local checkout or smoke checks are needed
- PR hygiene

Non-conforming developer branch names are BLOCKER findings unless the Orchestrator approved an exception.

## Transitions

- PASS: Code Review -> Functional Review
- FAIL: Code Review -> Blocked

Full workflow details live in `.agents/skills/code-review-pr/references/code-reviewer-workflow.md`.
