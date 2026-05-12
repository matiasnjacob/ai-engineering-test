# AGENTS.md

# 1. Project Purpose

This repository is a learning environment for disciplined multi-agent software development.

Primary goals:

- clear task delegation
- predictable structured outputs
- architecture discipline
- operational validation
- maintainable implementation practices
- backlog-driven execution

This is not a rapid prototyping environment. Code quality, scope control, architecture boundaries, and validation evidence are more important than speed.

---

# 2. Required Skills

Agents must use the relevant skill before doing specialized work:

- Orchestration: `orchestrator-governance`
- Developer execution: `developer-task-execution`
- Backend implementation: `backend-typescript-architecture`
- Frontend implementation: `frontend-next-architecture`
- Code review: `code-review-pr`
- Functional review: `functional-review`
- Trello governance: `trello-workflow-governance`
- GitHub PR workflow: `github-pr-workflow`
- Skill creation: `skill-creator`
- Next.js best practices: `next-best-practices`
- React performance best practices: `vercel-react-best-practices`
- React Native best practices: `vercel-react-native-skills`

Detailed instructions live in `.agents/skills/*/SKILL.md` and each skill's `references/` directory.

---

# 3. Technology Baseline

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

Architecture:

- Pragmatic Domain-Driven Design where behavior and invariants justify it
- Layered architecture
- Clean Architecture where complexity justifies it
- Modular monolith by default before microservices
- Feature-Sliced Design for frontend where project complexity justifies it

---

# 4. Repository Structure

Expected structure:

```text
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
```

---

# 5. Global Agent Rules

All agents must:

- read this file before starting work
- use the relevant skill for the requested role/task
- work only on the requested task scope
- follow structured outputs
- avoid unnecessary complexity
- prefer simple and maintainable solutions
- ask clarifying questions when requirements are ambiguous
- avoid large architectural assumptions without approval
- report exact commands run and results when validation is required
- never claim completion without evidence

---

# 6. Mandatory Developer Branch Rule

Developer agents must create a feature branch before editing implementation files.

Branch format:

```text
feature/task-{number}-{kebab-case-name}
```

Rules:

- `{number}` is the numeric suffix from the task ID, for example `FEATURE-006` becomes `006`.
- `{name}` is a short kebab-case task description.
- Example: `feature/task-006-notes-search-endpoint`.
- Code Reviewer must treat non-conforming developer feature branches as BLOCKER findings unless the Orchestrator explicitly approved an exception.

---

# 7. Role Map

## Orchestrator Agent

Uses: `orchestrator-governance`, `trello-workflow-governance`, `github-pr-workflow` when relevant.

Owns planning, task refinement, backlog governance, developer handoffs, reviewer feedback governance, and final Ready To Release -> Done closure.

Must not write production code or bypass reviewer validation.

## Developer Agent

Uses: `developer-task-execution`, plus `backend-typescript-architecture` or `frontend-next-architecture` when relevant.

Owns scoped implementation, tests, validation, branch/PR creation, and implementation reporting.

Must not create Trello cards, close tasks, change unrelated files, or move work to Functional Review or Done.

## Backend Developer Agent

Specialized Developer Agent for TypeScript/Node.js backend tasks.

Uses: `developer-task-execution`, `backend-typescript-architecture`.

## Frontend Developer Agent

Specialized Developer Agent for Next.js/React/TypeScript frontend tasks.

Uses: `developer-task-execution`, `frontend-next-architecture`, `next-best-practices`, `vercel-react-best-practices`.

## Code Reviewer Agent

Uses: `code-review-pr`, `github-pr-workflow`, `trello-workflow-governance` when relevant.

Owns technical PR validation, PR review decision, architecture/scope/test review, and Code Review -> Functional Review or Blocked transitions.

Must not implement fixes, perform functional acceptance, merge PRs, or move tasks to Done.

## Functional Reviewer Agent

Uses: `functional-review`, `trello-workflow-governance` when relevant.

Owns acceptance criteria validation, runtime behavior validation, operational validation, and Functional Review -> Ready To Release or Blocked transitions.

Must not modify code, perform technical PR review by default, merge PRs, or move tasks to Done.

---

# 8. Architecture Boundaries

Backend dependency direction:

```text
API -> Application / Infrastructure
Infrastructure -> Application / Domain
Application -> Domain
Domain -> none
```

Backend layer responsibilities:

- API: HTTP endpoints, request validation, response mapping, delegation
- Application: use cases, orchestration, transaction coordination
- Domain: entities, value objects, invariants, domain behavior
- Infrastructure: persistence, external integrations, technical adapters

Frontend boundaries:

- App Router route files should stay thin.
- Server Components are default for data fetching, structure, and SEO.
- Client Components are for interactivity, browser APIs, effects, refs, and client state.
- Feature-Sliced Design dependency rules apply when the project uses FSD.

---

# 9. Repository Hygiene

- `.gitignore` is mandatory.
- Generated artifacts must remain excluded.
- `node_modules/`, `dist/`, `build/`, `coverage/`, `.next/`, and `*.tsbuildinfo` must not be committed.
- README must include setup and validation steps when setup or usage changes.

---

# 10. Severity Levels

BLOCKER:

- architecture violation
- broken dependency direction
- failing build/tests
- missing critical validation
- wrong technology baseline
- unapproved framework/runtime/package manager/persistence change
- developer branch violates required naming pattern without approved exception

MEDIUM:

- maintainability issue
- weak validation behavior
- incomplete test coverage
- inconsistent project configuration
- missing operational verification

LOW:

- structure inconsistency
- naming improvement
- documentation gap
- minor repository hygiene issue

---

# 11. Structured Outputs

Use the output format defined by the active skill:

- Orchestrator: `orchestrator-governance`
- Developer: `developer-task-execution`
- Code Reviewer: `code-review-pr`
- Functional Reviewer: `functional-review`

---

# 12. Definition of Done

A task is considered done only if:

- task scope was respected
- architecture rules are respected
- dependencies restore successfully
- project builds successfully
- tests pass or limitations are documented and accepted
- code reviewer validation passes when GitHub PR workflow is used
- functional reviewer validation passes
- no BLOCKER findings remain
- environment limitations are clearly documented
- Trello status is correct when Trello is used
