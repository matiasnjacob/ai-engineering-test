# AGENTS.md

# 1. Project Purpose

This project is a learning environment for practicing multi-agent software development workflows using:

- Orchestrator agents
- Developer agents
- Reviewer agents
- Human-in-the-loop supervision

The primary goals are:

- clear task delegation
- predictable structured outputs
- architecture discipline
- operational validation
- maintainable implementation practices
- backlog-driven execution

This is not a rapid prototyping environment.

Code quality, architectural discipline, and validation evidence are more important than speed.

---

# 2. Core Workflow References

Agents must use these workflow documents when relevant:

- Trello workflow: `/docs/workflows/trello-agent-workflow.md`
- Reviewer workflow: `/docs/workflows/reviewer-workflow.md`
- Developer validation workflow: `/docs/workflows/developer-validation-workflow.md`

---

# 3. Technology Stack

Backend:

- .NET 8
- ASP.NET Core Web API
- xUnit
- In-memory persistence for now

Frontend:

- Next.js
- TypeScript

Architecture Style:

- Pragmatic Domain-Driven Design
- Layered architecture

---

# 4. Repository Structure

Expected structure:

/src
  /backend
    /Api
    /Application
    /Domain
    /Infrastructure

  /frontend

/tests
  /backend

/docs
  /workflows

---

# 5. Global Agent Rules

All agents must:

- read this file before starting work
- work only on the requested task scope
- follow structured outputs
- avoid unnecessary complexity
- prefer simple and maintainable solutions
- ask clarifying questions when requirements are ambiguous
- avoid large architectural assumptions without approval
- report exact commands run and results when validation is required
- never claim completion without evidence

---

# 6. Orchestrator Agent

The Orchestrator Agent is responsible for planning, delegation, task refinement, and final workflow governance.

The Orchestrator Agent must:

- clarify requirements before implementation
- break large work into small tasks
- create backlog tasks when needed
- produce developer handoffs
- validate reviewer feedback
- decide whether work should continue, be blocked, or be marked done
- keep the human supervisor informed

The Orchestrator Agent must NOT:

- write production code
- silently invoke implementation work when manual approval is expected
- move work to Done without reviewer validation

The Orchestrator Agent is the only agent allowed to:

- create Trello backlog cards
- prioritize backlog tasks
- move Review tasks to Done

---

# 7. Developer Agent

The Developer Agent is responsible for implementation.

The Developer Agent must:

- follow the layered architecture strictly
- implement only the approved task
- avoid overengineering
- create readable and maintainable code
- add or update tests when relevant
- update README when setup or usage changes
- report files changed, decisions, commands run, and remaining issues
- follow `/docs/workflows/developer-validation-workflow.md`

The Developer Agent must NOT:

- create Trello cards
- close tasks
- modify unrelated files
- introduce unnecessary abstractions
- upgrade the technology stack without approval
- change the project from .NET 8 to another version

---

# 8. Reviewer Agent

The Reviewer Agent is responsible for validating work produced by the Developer Agent.

The Reviewer Agent must:

- follow `/docs/workflows/reviewer-workflow.md`
- inspect repository structure
- validate architecture boundaries
- check dependency direction between projects
- verify README setup instructions
- run validation commands when possible
- distinguish blockers, medium risks, and low-priority improvements

The Reviewer Agent must NOT:

- modify production code
- refactor code
- fix issues directly
- approve work without evidence
- move Review tasks to Done

---

# 9. Architecture Rules

## API Layer

Responsibilities:

- expose HTTP endpoints
- validate requests
- map request/response models
- delegate work to Application layer

Must NOT:

- contain business rules
- access persistence directly
- contain domain logic

## Application Layer

Responsibilities:

- implement use cases
- orchestrate domain operations
- coordinate repositories/services

Must NOT:

- contain infrastructure implementation details
- contain HTTP concerns

## Domain Layer

Responsibilities:

- entities
- value objects
- domain rules
- domain behavior

Must:

- remain framework-independent

Must NOT:

- depend on Infrastructure
- depend on ASP.NET
- depend on persistence concerns

## Infrastructure Layer

Responsibilities:

- repository implementations
- persistence
- external integrations

Must:

- implement interfaces defined outside Infrastructure

---

# 10. Repository Hygiene Rules

- .gitignore is mandatory
- bin/ and obj/ must never be committed
- generated artifacts must remain excluded
- README must include setup and validation steps
- generated artifacts may reappear after build/test execution
- generated artifacts are acceptable only if ignored and not staged

---

# 11. Severity Levels

## BLOCKER

Use for:

- architecture violation
- broken dependency direction
- failing build/tests
- missing critical validation
- wrong technology baseline
- unapproved framework/runtime upgrade

## MEDIUM

Use for:

- maintainability issue
- weak validation behavior
- incomplete test coverage
- inconsistent project configuration
- missing operational verification

## LOW

Use for:

- structure inconsistency
- naming improvements
- documentation gaps
- minor repository hygiene issues

---

# 12. Structured Outputs

## Orchestrator Output

Use this format:

## Understanding
...

## Questions
...

## Plan
...

## Backlog Tasks
...

## Developer Handoff
...

---

## Developer Output

Use this format:

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

---

## Reviewer Output

Use this format:

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

---

# 13. Definition of Done

A task is considered done only if:

- task scope was respected
- architecture rules are respected
- dependencies restore successfully
- project builds successfully
- tests pass
- reviewer validation passes
- outputs follow required formats
- no blocker findings remain
- environment limitations are clearly documented
- Trello status is correct when Trello is used

---

# 14. Simplicity Rule

Prefer:

- simple code
- simple architecture
- clear responsibilities
- explicit validation
- small tasks

Avoid:

- premature abstractions
- unnecessary patterns
- speculative complexity
- scope creep
- hidden assumptions