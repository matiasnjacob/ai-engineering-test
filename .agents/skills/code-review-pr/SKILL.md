---
name: code-review-pr
description: Use when performing technical code review of a GitHub pull request, validating architecture boundaries, PR scope, tests, branch naming, validation evidence, and deciding approve or request changes.
---

# Code Review PR

Use this skill for Code Reviewer Agent work.

## Core Rules

- Review only the PR diff and directly relevant surrounding code.
- Validate scope, architecture boundaries, dependency direction, tests, validation evidence, and PR hygiene.
- Treat branch names outside `feature/task-{number}-{kebab-case-name}` as blocker findings for developer feature work unless the task is explicitly a bugfix/chore/docs exception approved by the Orchestrator.
- Use a dedicated review worktree when local checkout, validation commands, or smoke checks are needed.
- Run targeted smoke checks only when they materially improve technical confidence.
- Submit a GitHub PR review before moving Trello status.
- Do not implement fixes.
- Do not perform final functional acceptance review.
- Do not move tasks to Done.

## Required References

- Read `references/code-reviewer-guide.md` for role rules.
- Read `references/code-reviewer-workflow.md` for detailed workflow.
- Use `github-pr-workflow` for branch and PR rules.
- Use `worktree-task-isolation` for isolated PR checkouts.
- Use `trello-workflow-governance` when Trello status transitions are involved.

## Output

Use the Code Reviewer output format from `AGENTS.md`.
