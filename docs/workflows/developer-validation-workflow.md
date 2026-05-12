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
6. Ask questions if the task is ambiguous.

---

# Implementation Rules

The Developer Agent must:

- implement only the approved task
- keep changes small
- respect the approved TypeScript and Node.js backend baseline
- avoid unapproved runtime, framework, package manager, or persistence changes
- avoid unrelated refactors
- update tests when relevant
- update README when setup or usage changes

---

# GitHub PR Requirements

When GitHub PR workflow is enabled, the Developer Agent must:

1. Read the Trello task.
2. Confirm it is in Ready.
3. Create a branch using the Task ID.
4. Implement only the task scope.
5. Run validation commands.
6. Commit scoped changes.
7. Push the branch.
8. Create a GitHub PR.
9. Add the PR URL to the Trello card.
10. Move the Trello card from In Progress to Code Review.

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
npm run build --if-present
```

Use the repository's existing package manager and scripts. If the project uses `pnpm`, `yarn`, `bun`, or another approved tool, run the equivalent install, typecheck, lint, test, and build commands and report the exact commands used.

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

## Files Changed

...

## Decisions

...

## Commands Run

...

## Remaining Issues

...
