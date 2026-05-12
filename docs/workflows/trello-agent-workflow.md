# Trello Agent Workflow

Lightweight index for Trello status governance.

## Required Skill

- `trello-workflow-governance`

## Lists

```text
Backlog -> Ready -> In Progress -> Code Review -> Functional Review -> Ready To Release -> Done
```

Blocked may be used when validation fails or human decision is required.

## Allowed Transitions

| Agent | From | To |
|---|---|---|
| Orchestrator | Backlog | Ready |
| Developer | Ready | In Progress |
| Developer | In Progress | Code Review |
| Code Reviewer | Code Review | Functional Review |
| Code Reviewer | Code Review | Blocked |
| Functional Reviewer | Functional Review | Ready To Release |
| Functional Reviewer | Functional Review | Blocked |
| Orchestrator | Ready To Release | Done |
| Orchestrator | Any | Blocked |

Every transition must include a Trello comment with agent name, task ID, previous status, new status, reason, validation evidence when applicable, and remaining issues.

Full workflow details live in `.agents/skills/trello-workflow-governance/references/trello-workflow.md`.
