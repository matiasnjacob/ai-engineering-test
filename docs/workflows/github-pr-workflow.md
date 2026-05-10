# GitHub PR Workflow

## Purpose

GitHub is used as the source of truth for code changes.

Trello tracks task status.
GitHub tracks implementation history, branches, commits, pull requests, and code review.

Every implementation task must result in a focused GitHub pull request.

---

## Branch Naming

Branches must include the Trello Task ID.

Use:

```text
feature/<TASK-ID>-short-description
bugfix/<TASK-ID>-short-description
chore/<TASK-ID>-short-description
docs/<TASK-ID>-short-description
```

Examples:

```text
feature/FEATURE-006-notes-search-endpoint
bugfix/BUG-002-search-endpoint-tests
chore/LOW-001-clean-build-artifacts
docs/MEDIUM-001-update-validation-docs
```

---

## Developer Branch Rules

The Developer Agent must:

1. Read the Trello task.
2. Confirm the task is in Ready.
3. Move the task Ready -> In Progress.
4. Create a feature branch using the Task ID.
5. Implement only the task scope.
6. Run validation commands.
7. Commit scoped changes.
8. Push the branch.
9. Create a GitHub PR.
10. Add the PR URL to the Trello card.
11. Move the Trello card In Progress -> Code Review.

The Developer Agent must NOT:

- commit unrelated files
- mix multiple Trello tasks in one PR
- push directly to main
- create a PR without validation evidence
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

- [ ] dotnet restore src/backend/Binagora.Backend.sln
- [ ] dotnet build src/backend/Binagora.Backend.sln -c Release
- [ ] dotnet test src/backend/Binagora.Backend.sln -c Release

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
| Reviewer | Functional Review | Ready To Release |
| Reviewer | Functional Review | Blocked |
| Orchestrator | Ready To Release | Done |

---

## Code Review Gate

A task cannot move to Functional Review until:

- PR exists
- PR references Trello Task ID
- branch name includes Task ID
- validation evidence is present
- Code Reviewer passes the PR or leaves only acceptable LOW findings

---

## Functional Review Gate

A task cannot move to Done until:

- Code Review is complete
- Functional Review is complete
- Reviewer status is PASS
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
