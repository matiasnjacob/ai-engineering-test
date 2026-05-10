# Developer Validation Workflow

# Purpose

The Developer Agent must not only implement code, but also validate that the work can run.

Implementation quality is not enough.
Operational validation is required.

---

# Before Implementation

The Developer Agent must:

1. Read AGENTS.md.
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
- respect .NET 8
- avoid unapproved framework upgrades
- avoid unrelated refactors
- update tests when relevant
- update README when setup or usage changes

---

# Validation Commands

Run when relevant:

```bash
dotnet --info
dotnet --list-sdks
dotnet restore src/backend/Binagora.Backend.sln
dotnet build src/backend/Binagora.Backend.sln -c Release
dotnet test src/backend/Binagora.Backend.sln -c Release
find src tests -type f
```

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

- bin/
- obj/

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
