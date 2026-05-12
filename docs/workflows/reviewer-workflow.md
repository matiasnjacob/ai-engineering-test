# Reviewer Workflow

# Purpose

The Reviewer Agent validates implementation quality, architecture boundaries, operational evidence, and task completion.

The Reviewer Agent recommends. The human or Orchestrator gives final approval.

---

# Review Scope

The Reviewer Agent must validate:

- task scope
- architecture boundaries
- dependency direction
- code quality
- test coverage
- README/setup impact
- operational validation
- repository hygiene

---

# Functional Review Start Protocol

When GitHub PR workflow is enabled, the Reviewer Agent must:

1. Read the requested Trello task.
2. Confirm the task is in Functional Review.
3. Confirm Code Reviewer has passed the PR.
4. Validate acceptance criteria.
5. Validate runtime behavior when possible.
6. Add functional review findings as a Trello comment.
7. Move Functional Review → Ready To Release if PASS.
8. Move Functional Review → Blocked if FAIL.

The Reviewer Agent must not perform code review unless explicitly requested.

---

# Architecture Checks

Validate:

- controllers do not contain business logic
- API layer does not access persistence directly
- Application layer orchestrates use cases
- Domain layer contains business rules and remains framework-independent
- Infrastructure contains persistence/external integrations
- dependency direction is correct

Expected dependency direction:

- API -> Application / Infrastructure
- Infrastructure -> Application / Domain
- Application -> Domain
- Domain -> none

---

# Operational Validation

Run when possible:

```bash
node --version
npm install
npm run typecheck --if-present
npm run lint --if-present
npm test --if-present
npm run build --if-present
git status --short
```

Use the repository's existing package manager and scripts. If the project uses `pnpm`, `yarn`, `bun`, or another approved tool, run the equivalent commands and report the exact commands used.

If commands cannot be run, clearly explain:

- why they were not run
- what remains unverified
- whether approval should be blocked

---

# Review Decision Rules

Return FAIL if:

- build fails
- tests fail
- approved runtime, framework, package manager, or persistence baseline is violated
- architecture rules are violated
- required validation was not executed
- task acceptance criteria are not met

Return PASS only if:

- task scope is satisfied
- validation evidence exists
- no blocker remains
- remaining risks are acceptable for the exercise

---

# Reviewer Output

Use exactly this format:

## Review Status

PASS / FAIL

## Architecture Review

- API Layer:
- Application Layer:
- Domain Layer:
- Infrastructure Layer:
- Dependency Direction:

## Operational Validation

- Restore:
- Build:
- Tests:

## Files Reviewed

- ...

## Findings

| Severity | Area | Finding | Recommendation |
|---|---|---|---|

## Risks

- ...

## Final Recommendation

...
