# GitHub PR Workflow

Lightweight index for branch, commit, pull request, and PR gate rules.

## Required Skills

- `github-pr-workflow`
- `worktree-task-isolation`

## Mandatory Developer Branch Rule

Developer agents must create or reuse a task worktree and feature branch before editing implementation files.

Branch format:

```text
feature/task-{number}-{kebab-case-name}
```

Rules:

- `{number}` is the numeric suffix from the task ID, for example `FEATURE-006` becomes `006`.
- `{name}` is a short kebab-case task description.
- Example: `feature/task-006-notes-search-endpoint`.
- Non-conforming developer feature branches are BLOCKER code review findings unless the Orchestrator explicitly approved an exception.

## Worktree Requirements

- Use one task worktree per implementation task by default.
- Worktrees are mandatory when more than one active task exists for the same repository.
- Work only inside the task worktree after it is created.
- Report the worktree path in implementation and PR evidence.

## PR Requirements

- PR title includes the task ID.
- PR body includes summary, changes, validation evidence, architecture notes, and risks.
- PR is scoped to one task.
- Generated artifacts are excluded.
- Validation evidence is present.

Full workflow details live in `.agents/skills/github-pr-workflow/references/github-pr-workflow.md`.
