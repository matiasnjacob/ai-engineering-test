# Developer Validation Workflow

# Purpose

The Developer Agent must not only implement code, but also validate that the work can run.

Implementation quality is not enough.
Operational validation is required.

---

# Before Implementation

The Developer Agent must:

1. Read ../../AGENTS.md.
2. Read the requested task.
3. Confirm scope.
4. Confirm architecture boundaries.
5. Confirm current technology baseline.
6. Create or reuse the task worktree before editing implementation files.
7. Ask questions if the task is ambiguous.

Use:

```bash
/Users/matiasbinagora/Projects/_agentic-programming/scripts/create-task-worktree.sh <repo-path> <TASK-ID> <kebab-task-name> [base-branch]
```

Work only inside the returned worktree path.

---

# Implementation Rules

The Developer Agent must:

- implement only the approved task
- keep changes small
- respect the approved TypeScript, Node.js, and framework baseline
- avoid unapproved runtime, framework, package manager, styling system, or persistence changes
- avoid unrelated refactors
- update tests when relevant
- update README when setup or usage changes

---

# GitHub PR Requirements

When GitHub PR workflow is enabled, the Developer Agent must:

1. Read the Trello task.
2. Confirm it is in Ready.
3. Move the task Ready -> In Progress.
4. Create or reuse a task worktree.
5. Create `feature/task-{number}-{kebab-case-name}` in the task worktree before editing implementation files.
6. Implement only the task scope inside the task worktree.
7. Run validation commands inside the task worktree.
8. Commit scoped changes.
9. Push the branch.
10. Create a GitHub PR.
11. Add the PR URL and worktree path to the Trello card.
12. Move the Trello card from In Progress to Code Review.

The Developer Agent must NOT:

- push directly to main
- create a PR without Task ID
- mix multiple tasks in one PR
- include generated artifacts
- move cards to Functional Review, Review, or Done

---

# Validation Commands

Run when relevant:

```bash
node --version
npm --version
npm install
npm run typecheck --if-present
npm run lint --if-present
npm test --if-present
npm run test:e2e --if-present
npm run test:a11y --if-present
npm run build --if-present
```

Use the repository's existing package manager and scripts. If the project uses `pnpm`, `yarn`, `bun`, or another approved tool, run the equivalent install, typecheck, lint, unit test, end-to-end test, accessibility test, and build commands when available and report the exact commands used.

---

# If Validation Fails

The Developer Agent must:

- stop and report the issue
- include exact failing command
- include relevant error output
- explain what remains unverified
- not claim completion

---

# Generated Artifacts

Build and test commands may generate:

- node_modules/
- dist/
- build/
- coverage/
- .next/
- *.tsbuildinfo

These artifacts are acceptable only if:

- ignored by .gitignore
- not staged
- not committed

---

# Developer Output

Use exactly this format:

## Implementation Summary

...

## Worktree

- Path:
- Branch:

## Files Changed

...

## Decisions

...

## Commands Run

...

## Remaining Issues

...
