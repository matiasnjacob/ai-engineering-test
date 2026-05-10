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
dotnet restore src/backend/Binagora.Backend.sln
dotnet build src/backend/Binagora.Backend.sln -c Release
dotnet test src/backend/Binagora.Backend.sln -c Release
git status --short
find src tests -type f
```

If commands cannot be run, clearly explain:

- why they were not run
- what remains unverified
- whether approval should be blocked

---

# Review Decision Rules

Return FAIL if:

- build fails
- tests fail
- .NET baseline is violated
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
