# Binagora

Learning environment for practicing multi-agent software development workflows.

## Backend

The backend foundation is TypeScript on Node.js.

The concrete backend framework, package manager, test framework, and persistence technology are selected per task context and must be documented when introduced.

Expected projects and modules:

- `src/backend/Api`
- `src/backend/Application`
- `src/backend/Domain`
- `src/backend/Infrastructure`
- `tests/backend`

## Backend validation

Run backend validation from the repository root using the approved package manager and scripts for the current task.

Typical npm-based validation:

```bash
node --version
npm install
npm run typecheck --if-present
npm run lint --if-present
npm test --if-present
npm run build --if-present
```

If the project uses `pnpm`, `yarn`, `bun`, or another approved tool, run the equivalent install, typecheck, lint, test, and build commands and report the exact commands used.

## Frontend

The frontend foundation is Next.js, React, and TypeScript.

New frontend work should default to the Next.js App Router unless the task explicitly targets a legacy Pages Router application.

Expected frontend location:

- `src/frontend`
- `tests/frontend`

Frontend architecture, styling, state management, test tooling, and deployment assumptions are selected per task context and must be documented when introduced.

## Frontend validation

Run frontend validation from the repository root using the approved package manager and scripts for the current task.

Typical npm-based validation:

```bash
node --version
npm install
npm run typecheck --if-present
npm run lint --if-present
npm test --if-present
npm run test:e2e --if-present
npm run test:a11y --if-present
npm run build --if-present
```

If the project uses `pnpm`, `yarn`, `bun`, or another approved tool, run the equivalent install, typecheck, lint, unit test, end-to-end test, accessibility test, and build commands when available and report the exact commands used.

## Agent guidance

Developer agents must follow:

- `AGENTS.md`
- `docs/workflows/developer-validation-workflow.md`
- `docs/agents/backend-developer-agent.md`
- `docs/agents/frontend-developer-agent.md`
