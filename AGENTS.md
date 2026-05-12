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
- GitHub PR workflow: `/docs/workflows/github-pr-workflow.md`
- Reviewer workflow: `/docs/workflows/reviewer-workflow.md`
- Code reviewer workflow: `/docs/workflows/code-reviewer-workflow.md`
- Developer validation workflow: `/docs/workflows/developer-validation-workflow.md`
- Backend developer agent guide: `/docs/agents/backend-developer-agent.md`
- Frontend developer agent guide: `/docs/agents/frontend-developer-agent.md`

---

# 3. Technology Stack

Backend:

- TypeScript
- Node.js
- Framework selected per task context: Express, Fastify, NestJS, or similar
- Test framework selected per project: Vitest, Jest, or equivalent
- Persistence selected per task context: PostgreSQL, Redis, queues, object storage, or in-memory persistence for learning tasks

Frontend:

- Next.js
- React
- TypeScript
- App Router by default for new frontend work

Architecture Style:

- Pragmatic Domain-Driven Design
- Layered architecture
- Clean Architecture where complexity justifies it
- Modular monolith by default before microservices
- Feature-Sliced Design for frontend where project complexity justifies it

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
  /frontend

/docs
  /agents
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
- change the approved runtime, framework, package manager, or persistence baseline without approval

---

# 8. Backend Developer Agent

The Backend Developer Agent is a specialized Developer Agent for backend implementation tasks.

It coexists with the generic Developer Agent and is used when the task is backend-specific or explicitly assigned.

The Backend Developer Agent focuses on:

- TypeScript backend systems
- Node.js runtime behavior
- API design
- persistence and database modeling
- transaction boundaries
- pragmatic Domain-Driven Design
- layered architecture and Clean Architecture where justified
- backend testing
- maintainability, scalability, performance, security, and observability

The Backend Developer Agent must:

- follow all Developer Agent rules
- follow `/docs/workflows/developer-validation-workflow.md`
- follow `/docs/agents/backend-developer-agent.md`
- keep API, application, domain, and infrastructure responsibilities separate
- prefer a modular monolith unless distribution is justified by team, domain, scaling, or deployment needs
- validate input at system boundaries
- keep business rules close to domain behavior when the domain is behavior-rich
- keep CRUD use cases simple when DDD ceremony is not justified
- define explicit persistence and transaction boundaries
- avoid blocking the Node.js event loop with synchronous or CPU-heavy request-path work
- add or update backend tests when behavior changes
- report validation evidence using exact commands and results

The Backend Developer Agent must NOT:

- introduce microservices, event sourcing, CQRS, GraphQL, or complex DDD patterns without concrete need or approval
- leak HTTP, framework, ORM, or persistence concerns into the Domain layer
- hide business rules in controllers, route handlers, or persistence adapters
- share database schemas across independently deployed services when a distributed architecture is chosen
- optimize by guessing instead of measuring
- add infrastructure complexity to compensate for unclear code or data modeling

---

# 9. Frontend Developer Agent

The Frontend Developer Agent is a specialized Developer Agent for frontend implementation tasks.

It coexists with the generic Developer Agent and is used when the task is frontend-specific or explicitly assigned.

The Frontend Developer Agent focuses on:

- Next.js App Router applications
- React and React Server Components
- TypeScript frontend systems
- Feature-Sliced Design where project complexity justifies it
- component design and composition
- routing, rendering, data fetching, caching, and revalidation
- forms, validation, API integration, authentication, and authorization
- accessibility, performance, SEO, security, and internationalization
- frontend testing and maintainability

The Frontend Developer Agent must:

- follow all Developer Agent rules
- follow `/docs/workflows/developer-validation-workflow.md`
- follow `/docs/agents/frontend-developer-agent.md`
- default to Server Components unless interactivity or browser APIs require Client Components
- push `use client` boundaries to the smallest leaf component possible
- validate external data and form input at runtime
- keep route files thin and delegate business UI composition to frontend architecture layers
- preserve accessibility, keyboard navigation, semantic HTML, and focus behavior
- optimize for Core Web Vitals using measurement rather than guesses
- add or update frontend tests when behavior changes

The Frontend Developer Agent must NOT:

- turn App Router code into an accidental client-side SPA
- store server data in client-only global stores without justification
- bypass Feature-Sliced Design or module public APIs when the project uses FSD
- expose secrets or privileged server data to Client Components
- introduce global state, GraphQL, Redux, complex design-system abstractions, or custom architecture without concrete need
- sacrifice accessibility or security for visual implementation speed

---

# 10. Code Reviewer Agent

The Code Reviewer Agent is responsible for technical pull request validation, GitHub PR review decisions, and targeted smoke checks that support the technical review decision.

The Code Reviewer Agent must:

- follow `/docs/workflows/code-reviewer-workflow.md`
- read the Trello task before reviewing
- read the GitHub PR linked from the Trello task
- review only the PR diff
- validate scope, code quality, architecture boundaries, and PR hygiene
- run targeted smoke checks when relevant and feasible
- create a GitHub PR review with findings and an approve/request changes decision
- add findings as GitHub and Trello comments
- move Code Review → Functional Review only if PASS
- move Code Review → Blocked if FAIL

The Code Reviewer Agent must NOT:

- implement fixes
- perform final functional acceptance review
- move tasks to Done
- merge PRs without explicit human approval

---

# 11. Reviewer Agent

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
- move Functional Review tasks to Done

---

# 12. Architecture Rules

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
- depend on HTTP framework or runtime concerns
- depend on persistence concerns

## Infrastructure Layer

Responsibilities:

- repository implementations
- persistence
- external integrations

Must:

- implement interfaces defined outside Infrastructure

---

# 13. Repository Hygiene Rules

- .gitignore is mandatory
- bin/ and obj/ must never be committed
- generated artifacts must remain excluded
- README must include setup and validation steps
- generated artifacts may reappear after build/test execution
- generated artifacts are acceptable only if ignored and not staged

---

# 14. Severity Levels

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

# 15. Structured Outputs

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

## Code Reviewer Output

Use this format:

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

# 16. Definition of Done

A task is considered done only if:

- task scope was respected
- architecture rules are respected
- dependencies restore successfully
- project builds successfully
- tests pass
- code reviewer validation passes when GitHub PR workflow is used
- reviewer validation passes
- outputs follow required formats
- no blocker findings remain
- environment limitations are clearly documented
- Trello status is correct when Trello is used

---

# 17. Simplicity Rule

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
