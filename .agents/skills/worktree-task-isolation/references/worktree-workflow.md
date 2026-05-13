# Worktree Workflow

## Purpose

Git worktrees isolate concurrent agent work so multiple tasks can proceed in separate branches without modifying the same checkout.

Use worktrees by default for implementation tasks. They are mandatory when more than one active task exists for the same repository.

---

## Location Convention

Task worktrees live under:

```text
/Users/matiasbinagora/Projects/.worktrees/<repo-name>/task-{number}-{kebab-case-name}
```

Review worktrees live under:

```text
/Users/matiasbinagora/Projects/.worktrees/<repo-name>/review-pr-{number}
```

Developer branch format remains:

```text
feature/task-{number}-{kebab-case-name}
```

---

## Developer Start Protocol

Before editing implementation files, the Developer Agent must:

1. Read `AGENTS.md` and the requested task.
2. Confirm task scope and base branch.
3. Create or reuse the task worktree.
4. Work only inside the task worktree.
5. Report the worktree path and branch in the implementation output.

Use:

```bash
/Users/matiasbinagora/Projects/_agentic-programming/scripts/create-task-worktree.sh <repo-path> <TASK-ID> <kebab-task-name> [base-branch]
```

Example:

```bash
/Users/matiasbinagora/Projects/_agentic-programming/scripts/create-task-worktree.sh . FEATURE-006 notes-search-endpoint main
```

---

## Orchestrator Rules

The Orchestrator Agent must:

- check active worktrees before assigning concurrent work in the same repository
- include task ID, branch name, and expected worktree path in Developer handoffs when known
- require separate worktrees for separate active tasks
- avoid asking two Developer Agents to edit the same project root

Use:

```bash
/Users/matiasbinagora/Projects/_agentic-programming/scripts/list-worktrees.sh <repo-path>
```

---

## Code Reviewer Rules

The Code Reviewer Agent should review PR diff remotely by default.

When local checkout, validation commands, or smoke checks are needed, the Code Reviewer Agent must use a review worktree and must not edit files.

Use:

```bash
/Users/matiasbinagora/Projects/_agentic-programming/scripts/create-review-worktree.sh <repo-path> <pr-number> [base-branch]
```

---

## Functional Reviewer Rules

When functional validation needs local execution, the Functional Reviewer Agent must use an isolated review worktree or a task-specific validation worktree. It must not reuse the Developer Agent's dirty worktree unless explicitly approved.

Functional Reviewer Agents must not edit code.

---

## Cleanup Rules

Remove worktrees only after the task is Done or cleanup is explicitly requested.

Use:

```bash
/Users/matiasbinagora/Projects/_agentic-programming/scripts/remove-task-worktree.sh <worktree-path>
```

Rules:

- refuse dirty worktrees by default
- keep branches by default
- use `--delete-branch` only when explicitly requested
- use `--force` only when explicitly approved

---

## Safety Rules

Agents must not:

- edit implementation files in the original project root once a task worktree exists
- share one worktree across unrelated active tasks
- remove dirty worktrees without explicit approval
- delete branches automatically
- bypass the required branch naming rule
