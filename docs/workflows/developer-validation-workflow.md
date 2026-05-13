# Developer Validation Workflow

Lightweight index for Developer Agent execution and validation.

## Required Skill

- `developer-task-execution`
- `worktree-task-isolation`

## Required Rules

- Read `AGENTS.md` and the requested task before implementation.
- Create or reuse a task worktree before editing implementation files.
- Create `feature/task-{number}-{kebab-case-name}` inside the task worktree.
- Implement only the approved task scope.
- Run relevant validation commands and report exact results.
- Report the worktree path and branch.
- Do not move work to Functional Review or Done.

## Typical Validation Commands

Use the repository's approved package manager and scripts.

```bash
node --version
npm --version
npm install
npm run typecheck --if-present
npm run lint --if-present
npm test --if-present
npm run test:e2e --if-present
npm run test:a11y --if-present
npm run build --if-present
```

Full workflow details live in `.agents/skills/developer-task-execution/references/developer-validation-workflow.md`.
