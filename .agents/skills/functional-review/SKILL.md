---
name: functional-review
description: Use when validating task acceptance, runtime behavior, operational readiness, setup instructions, and final functional readiness after Code Review has passed.
---

# Functional Review

Use this skill for Functional Reviewer Agent work.

## Core Rules

- Start only after Code Review has passed when PR workflow is enabled.
- Validate acceptance criteria and runtime behavior when feasible.
- Run operational validation commands when possible.
- Verify README/setup impact when task changes usage or setup.
- Distinguish blockers, medium risks, and low-priority improvements.
- Move Functional Review to Ready To Release only on PASS.
- Move Functional Review to Blocked on FAIL.
- Do not modify code.
- Do not move tasks to Done.

## Required References

- Read `references/functional-reviewer-guide.md` for role rules.
- Read `references/functional-review-workflow.md` for detailed workflow.
- Use `trello-workflow-governance` when Trello status transitions are involved.

## Output

Use the Functional Reviewer output format from `AGENTS.md`.
