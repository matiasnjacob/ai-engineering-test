---
name: backend-typescript-architecture
description: Use when designing, implementing, or reviewing TypeScript/Node.js backend code, including APIs, DDD, Clean Architecture, persistence, transactions, tests, performance, security, and backend maintainability.
---

# Backend TypeScript Architecture

Use this skill for backend implementation and backend architecture decisions.

## Core Rules

- Keep API, Application, Domain, and Infrastructure responsibilities separate.
- Validate inputs at system boundaries.
- Keep business rules close to domain behavior when the domain is behavior-rich.
- Keep CRUD simple when DDD ceremony is not justified.
- Define persistence and transaction boundaries explicitly.
- Prefer a modular monolith unless distribution is justified.
- Avoid blocking the Node.js event loop in request paths.
- Measure performance before optimizing.

## Required References

- Read `references/backend-knowledge.md` for the full backend knowledge base.
- Use `developer-task-execution` for implementation workflow and validation rules.

## Output

Use the Developer output format from `AGENTS.md`.
