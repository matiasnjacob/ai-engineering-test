---
name: developer-task-execution
description: Use when implementing an approved task, validating code, creating developer branches and pull requests, or following task execution rules for backend or frontend Developer Agents.
---

# Developer Task Execution

Use this skill for Developer Agent implementation work.

## Core Rules

- Implement only the approved task scope.
- Keep changes small and avoid unrelated refactors.
- Create or reuse a task worktree before editing implementation files.
- Create the feature branch inside the task worktree.
- Branch format is `feature/task-{number}-{kebab-case-name}`.
- Derive `{number}` from the numeric suffix of the task ID, for example `FEATURE-006` becomes `006`.
- Example branch: `feature/task-006-notes-search-endpoint`.
- Run relevant install, typecheck, lint, test, E2E, accessibility, and build commands when available.
- Report exact commands and results.
- Report the worktree path and branch.
- Do not move work to Functional Review or Done.

## Required References

- Read `references/developer-validation-workflow.md` for full validation workflow.
- Use `worktree-task-isolation` before editing implementation files.
- Use `backend-typescript-architecture` for backend implementation tasks.
- Use `frontend-next-architecture` for frontend implementation tasks.
- Use `github-pr-workflow` for branch, commit, and pull request rules.
- Use `trello-workflow-governance` when Trello status transitions are involved.

## Output

Use the Developer output format from `AGENTS.md`.
