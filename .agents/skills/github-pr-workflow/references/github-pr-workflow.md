# GitHub PR Workflow

## Purpose

GitHub is used as the source of truth for code changes.

Trello tracks task status.
GitHub tracks implementation history, branches, commits, pull requests, and code review.

Every implementation task must result in a focused GitHub pull request.

---

## Branch Naming

Developer agents must create a task worktree and feature branch before editing implementation files.

Use:

```text
feature/task-{number}-{kebab-case-name}
```

Examples:

```text
feature/task-006-notes-search-endpoint
feature/task-123-login-form-validation
```

Rules:

- `{number}` is the numeric suffix from the task ID, for example `FEATURE-006` becomes `006`.
- `{name}` is a short kebab-case task description.
- Non-conforming developer feature branches are BLOCKER findings unless the Orchestrator explicitly approved an exception.

---

## Worktree Isolation

Developer agents use one task worktree per implementation task by default.

Worktrees are mandatory when more than one active task exists for the same repository.

Task worktrees live under:

```text
/Users/matiasbinagora/Projects/.worktrees/<repo-name>/task-{number}-{kebab-case-name}
```

Review worktrees live under:

```text
/Users/matiasbinagora/Projects/.worktrees/<repo-name>/review-pr-{number}
```

Create task worktrees with:

```bash
/Users/matiasbinagora/Projects/_agentic-programming/scripts/create-task-worktree.sh <repo-path> <TASK-ID> <kebab-task-name> [base-branch]
```

Rules:

- work only inside the task worktree after it is created
- report worktree path and branch in implementation output
- reviewers use review worktrees when local checkout or smoke checks are needed
- keep branches by default when removing worktrees

---

## Developer Branch Rules

The Developer Agent must:

1. Read the Trello task.
2. Confirm the task is in Ready.
3. Move the task Ready -> In Progress.
4. Create or reuse a task worktree.
5. Create a feature branch using `feature/task-{number}-{kebab-case-name}` in the task worktree before editing implementation files.
6. Implement only the task scope inside the task worktree.
7. Run validation commands.
8. Commit scoped changes.
9. Push the branch.
10. Create a GitHub PR.
11. Add the PR URL and worktree path to the Trello card.
12. Move the Trello card In Progress -> Code Review.

The Developer Agent must NOT:

- commit unrelated files
- mix multiple Trello tasks in one PR
- push directly to main
- create a PR without validation evidence
- edit implementation files in the original project root once a task worktree exists
- move a task to Functional Review or Done

---

## Commit Rules

Commits should be small and scoped.

Commit messages should include the Task ID.

Examples:

```text
FEATURE-006 add notes search endpoint
BUG-002 add API tests for notes search
LOW-001 remove generated artifacts
```

---

## Pull Request Title

PR titles must include the Task ID.

Example:

```text
FEATURE-006 Add notes search endpoint
```

---

## Pull Request Description Template

Every PR must include:

```md
## Task

Trello: <TASK-ID>

## Summary

...

## Changes

- ...

## Validation

- [ ] Install dependencies with the approved package manager
- [ ] Run typecheck when available
- [ ] Run lint when available
- [ ] Run tests when available
- [ ] Run end-to-end tests when available and relevant
- [ ] Run accessibility tests when available and relevant
- [ ] Run build when available

## Architecture Notes

...

## Risks / Remaining Issues

...
```

---

## Pull Request Scope Rules

A PR must be considered invalid if it:

- includes unrelated task work
- changes the technology baseline without approval
- modifies generated files
- mixes cleanup with feature work
- hides failing validation
- lacks Trello Task ID reference

---

## Status Transitions

When GitHub PR workflow is enabled:

| Agent | Trello From | Trello To |
|---|---|---|
| Developer | Ready | In Progress |
| Developer | In Progress | Code Review |
| Code Reviewer | Code Review | Functional Review |
| Code Reviewer | Code Review | Blocked |
| Functional Reviewer | Functional Review | Ready To Release |
| Functional Reviewer | Functional Review | Blocked |
| Orchestrator | Ready To Release | Done |

---

## Code Review Gate

A task cannot move to Functional Review until:

- PR exists
- PR references Trello Task ID
- branch name follows `feature/task-{number}-{kebab-case-name}` unless an exception was approved
- task worktree path is reported when local implementation used a worktree
- validation evidence is present
- Code Reviewer creates a GitHub PR review
- Code Reviewer approves the PR or leaves only acceptable LOW findings
- targeted smoke checks pass when they are needed for technical confidence

---

## Functional Review Gate

A task cannot move to Done until:

- Code Review is complete
- Functional Review is complete
- Functional Reviewer status is PASS
- no BLOCKER findings remain
- Orchestrator confirms final approval

---

## Safety Rules

Agents must never:

- merge PRs unless explicitly approved
- delete branches unless explicitly approved
- bypass code review
- bypass functional review
- change unrelated Trello cards
- change unrelated GitHub PRs
