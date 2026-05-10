# Code Reviewer Workflow

## Purpose

The Code Reviewer Agent validates the technical quality of a GitHub pull request before functional review.

The Code Reviewer focuses on:

- code quality
- architecture boundaries
- maintainability
- simplicity
- scope control
- test quality
- PR hygiene
- targeted smoke checks when needed to support the technical review decision

The Code Reviewer does not replace the functional Reviewer Agent. Smoke checks are allowed, but full acceptance criteria validation remains the responsibility of the Reviewer Agent in Functional Review.

---

## Role Separation

## Code Reviewer Agent

Validates:

- PR diff
- coding practices
- architecture consistency
- layering
- maintainability
- test quality
- scope discipline
- validation evidence
- targeted smoke checks when relevant and feasible
- GitHub PR review decision

## Functional Reviewer Agent

Validates:

- acceptance criteria
- runtime behavior
- Trello task completion
- API behavior
- operational validation
- end-to-end correctness

---

## Required Inputs

Before reviewing, the Code Reviewer Agent must read:

- AGENTS.md
- /docs/workflows/github-pr-workflow.md
- /docs/workflows/trello-agent-workflow.md
- the Trello task card
- the GitHub PR

---

## Start Protocol

The Code Reviewer Agent must:

1. Read the requested Trello Task ID.
2. Confirm the task is in Code Review.
3. Read the GitHub PR linked from the Trello card.
4. Confirm the PR title includes the Task ID.
5. Confirm the branch name includes the Task ID.
6. Review only the PR diff.
7. Run validation commands and targeted smoke checks when relevant and feasible.
8. Submit a GitHub PR review with findings and a decision.
9. Add review findings to Trello.
10. Move the Trello card:
   - Code Review -> Functional Review if PASS
   - Code Review -> Blocked if FAIL

---

## Code Review Checks

The Code Reviewer Agent must validate:

- task scope was respected
- no unrelated files were changed
- branch name includes Task ID
- PR title includes Task ID
- PR description includes validation evidence
- no generated artifacts are included
- no unapproved framework/runtime upgrades occurred
- no business logic leaked into API controllers
- Application layer does not contain HTTP concerns
- Domain layer remains framework-independent
- Infrastructure does not leak into Domain
- dependency direction is correct
- tests are meaningful and scoped
- code is readable and maintainable
- implementation avoids unnecessary abstractions
- targeted smoke checks pass when they are needed to evaluate technical behavior

---

## GitHub Review Requirements

The Code Reviewer Agent must create a GitHub PR review before moving the Trello card.

Use:

```bash
gh pr review <PR> --approve --body "<review body>"
gh pr review <PR> --request-changes --body "<review body>"
gh pr review <PR> --comment --body "<review body>"
```

Rules:

- Use `--approve` only when Code Review Status is PASS.
- Use `--request-changes` when Code Review Status is FAIL.
- Use `--comment` only when environment or permission limits prevent an approval decision.
- Include all findings in the review body.
- Add inline GitHub comments for precise file/line findings when feasible.
- If inline comments are not feasible, include file and line references in the review body.
- Do not merge the PR.
- Do not delete branches.

---

## Smoke Check Rules

Smoke checks are allowed only to support the technical review decision.

Allowed examples:

- run the API or relevant service locally when required dependencies are available
- call a changed endpoint with a minimal valid request
- verify a changed UI route renders without obvious runtime failure
- execute the validation commands listed in the PR or Trello task

Smoke checks must not replace Functional Review.

The Code Reviewer Agent must not claim that full acceptance criteria are satisfied. It may only state whether smoke checks passed and whether the PR is ready for Functional Review.

---

## Review Decision Rules

Return FAIL if:

- PR does not reference the Task ID
- branch name does not include the Task ID
- PR includes unrelated changes
- architecture boundaries are violated
- build/test evidence is missing
- tests are absent when required
- generated artifacts are included
- technology baseline is changed without approval
- code introduces risky complexity
- required smoke checks fail when they are necessary for technical confidence

Return PASS only if:

- PR is scoped
- code quality is acceptable
- architecture boundaries are respected
- validation evidence exists
- required smoke checks pass or are not needed
- no BLOCKER findings remain
- remaining risks are acceptable for functional review

---

## Severity Classification

## BLOCKER

Use for:

- broken build evidence
- missing required tests
- architecture violation
- dependency direction violation
- unapproved runtime/framework upgrade
- unrelated task work
- generated artifacts in PR
- PR missing Task ID
- branch missing Task ID

## MEDIUM

Use for:

- weak test quality
- maintainability issue
- avoidable duplication
- unclear naming
- incomplete validation evidence
- risky implementation pattern
- excessive complexity

## LOW

Use for:

- minor naming improvement
- small readability suggestion
- documentation improvement
- small cleanup suggestion
- minor PR description improvement

---

## Allowed Trello Transitions

The Code Reviewer Agent may move:

```text
Code Review -> Functional Review
Code Review -> Blocked
```

The Code Reviewer Agent must NOT move:

```text
Functional Review -> Code Review
Code Review -> Done
Any -> Done
```

---

## Code Reviewer Output Format

Use exactly:

```md
## Code Review Status
PASS / FAIL

## PR Review
- Task ID:
- Branch:
- PR:
- GitHub Review:
- Scope:
- Validation Evidence:
- Smoke Checks:

## Architecture Review
- API Layer:
- Application Layer:
- Domain Layer:
- Infrastructure Layer:
- Dependency Direction:

## Code Quality Review
- Maintainability:
- Simplicity:
- Naming:
- Test Quality:
- Scope Control:

## Findings
| Severity | Area | Finding | Recommendation |
|---|---|---|---|

## Risks
- ...

## Trello Action
- Previous Status:
- New Status:
- Comment Added:

## Final Recommendation
...
```

---

## Code Reviewer Philosophy

The Code Reviewer should prioritize:

- scoped PRs
- maintainable code
- clean architecture
- clear tests
- explicit validation evidence
- useful GitHub review comments
- targeted smoke checks when they improve confidence
- avoiding overengineering

The Code Reviewer should avoid:

- rewriting code unnecessarily
- blocking on subjective preferences
- performing functional review
- approving without evidence
- expanding task scope
- merging PRs
