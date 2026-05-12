---
name: frontend-next-architecture
description: Use when designing, implementing, or reviewing frontend code with Next.js, React, TypeScript, App Router, Server Components, Client Components, forms, state, accessibility, performance, SEO, security, and frontend architecture.
---

# Frontend Next Architecture

Use this skill for frontend implementation and frontend architecture decisions.

## Core Rules

- Default to Server Components unless interactivity or browser APIs require Client Components.
- Push `use client` boundaries to the smallest leaf component possible.
- Keep route files thin.
- Validate external data and form input at runtime.
- Preserve semantic HTML, keyboard navigation, focus behavior, and accessible errors.
- Keep state local by default and separate server state from client UI state.
- Use Feature-Sliced Design only when project complexity justifies it.
- Use installed `next-best-practices` and `vercel-react-best-practices` skills for Next.js and React performance details.

## Required References

- Read `references/frontend-knowledge.md` for the full frontend knowledge base.
- Use `developer-task-execution` for implementation workflow and validation rules.

## Output

Use the Developer output format from `AGENTS.md`.
