---
name: github-pr-workflow
description: Use when creating or reviewing GitHub branches, commits, pull requests, PR templates, validation evidence, and PR workflow gates for implementation tasks.
---

# GitHub PR Workflow

Use this skill whenever GitHub PR workflow is enabled.

## Core Rules

- Developer agents must create a feature branch before editing implementation files.
- Branch format is `feature/task-{number}-{kebab-case-name}`.
- Derive `{number}` from the numeric suffix of the task ID, for example `FEATURE-006` becomes `006`.
- Example: `feature/task-006-notes-search-endpoint`.
- Every implementation task must result in a focused PR unless explicitly exempted.
- PR title must include the task ID.
- PR body must include summary, changes, validation evidence, architecture notes, and risks.
- Do not mix unrelated task work in one PR.
- Do not push directly to main.
- Do not create a PR without validation evidence.

## Required References

- Read `references/github-pr-workflow.md` for full branch, commit, PR, and gate rules.
