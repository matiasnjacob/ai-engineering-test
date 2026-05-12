# Functional Reviewer Workflow

Lightweight index for functional acceptance and runtime validation.

## Required Skills

- `functional-review`
- `trello-workflow-governance` when Trello is used
- `github-pr-workflow` when PR workflow is used

## Review Gate

Functional Reviewer validates:

- acceptance criteria
- runtime behavior when feasible
- operational validation evidence
- setup/README impact
- remaining risks

Functional Review starts only after Code Review has passed when PR workflow is enabled.

## Transitions

- PASS: Functional Review -> Ready To Release
- FAIL: Functional Review -> Blocked

Full workflow details live in `.agents/skills/functional-review/references/functional-review-workflow.md`.
