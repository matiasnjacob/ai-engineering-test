# Worktree Workflow

Lightweight index for isolated task and review worktrees.

## Required Skill

- `worktree-task-isolation`

## Required Rules

- Use one worktree per implementation task by default.
- Worktrees are mandatory when more than one active task exists for the same repository.
- Developer worktrees use `feature/task-{number}-{kebab-case-name}` branches.
- Reviewers use dedicated review worktrees when local checkout or smoke checks are needed.
- Do not edit implementation files in the original project root once a task worktree exists.
- Do not remove dirty worktrees or delete branches unless explicitly approved.

Full workflow details live in `.agents/skills/worktree-task-isolation/references/worktree-workflow.md`.
