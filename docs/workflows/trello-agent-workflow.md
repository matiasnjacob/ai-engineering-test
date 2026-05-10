# Trello Agent Workflow

# Purpose

Trello is used as the source of truth for task status when enabled.

The goal is to avoid losing important decisions, refinements, and remediation tasks inside agent conversations.

---

# Board Lists

Use these lists:

- Backlog
- Ready
- In Progress
- Code Review
- Functional Review
- Ready To Release
- Blocked
- Done

## List Meaning

- Backlog: task exists but is not approved for work.
- Ready: approved for Developer execution.
- In Progress: Developer is actively working.
- Code Review: PR is ready for Code Reviewer.
- Functional Review: code review passed and task is ready for functional validation.
- Ready To Release: functional validation passed and task is ready for Orchestrator closure.
- Blocked: task failed validation or needs human decision.
- Done: Orchestrator approved final completion.

---

# Task ID Format

Task IDs must follow:

- LOW-001
- MEDIUM-001
- RISK-001
- BUG-001
- FEATURE-001

---

# Agent Permissions

## Orchestrator Agent

May:

- create cards
- prioritize cards
- move Backlog → Ready
- move Ready To Release → Done
- move any task → Blocked
- create remediation tasks from reviewer findings

Must NOT:

- implement tasks
- mark work Done without reviewer validation

## Developer Agent

May:

- read assigned task cards
- move Ready → In Progress
- move In Progress → Code Review
- add implementation comments

Must NOT:

- create cards
- close cards
- move cards to Done
- modify unrelated cards

## Reviewer Agent

May:

- read cards in Functional Review
- add review comments
- move Functional Review → Ready To Release if validation passes
- move Functional Review → Blocked if validation fails

Must NOT:

- create cards
- implement fixes
- move cards to Done

## Code Reviewer Agent

May:

- read cards in Code Review
- add code review comments
- move Code Review → Functional Review if validation passes
- move Code Review → Blocked if validation fails

Must NOT:

- implement fixes
- perform functional acceptance review
- move cards to Done

---

# Status Transition Rules

Allowed transitions:

| Agent | From | To |
|---|---|---|
| Orchestrator | Backlog | Ready |
| Developer | Ready | In Progress |
| Developer | In Progress | Code Review |
| Code Reviewer | Code Review | Functional Review |
| Code Reviewer | Code Review | Blocked |
| Reviewer | Functional Review | Ready To Release |
| Reviewer | Functional Review | Blocked |
| Orchestrator | Ready To Release | Done |
| Orchestrator | Any | Blocked |

No other transition is allowed without human approval.

---

# Card Template

Every card must include:

## Context
...

## Task
...

## Acceptance Criteria
- ...

## Suggested Agent
Developer / Code Reviewer / Reviewer / Orchestrator

## Validation Commands
- ...

## Risk Notes
...

---

# Required Comments

Every status transition must add a comment with:

- agent name
- task ID
- previous status
- new status
- reason
- summary of work or validation
- commands run when applicable
- remaining issues

---

# Developer Start Protocol

Before implementing a Trello task, the Developer Agent must:

1. Read the requested card by task ID.
2. Confirm the card is in Ready.
3. Move the card to In Progress.
4. Add a comment explaining the transition.
5. Implement only the task scope.
6. Add the PR URL to the Trello card when GitHub PR workflow is enabled.
7. Move the card to Code Review when finished.
8. Add a final implementation comment.

If the card is not in Ready, the Developer Agent must stop.

---

# Reviewer Start Protocol

Before reviewing a Trello task, the Reviewer Agent must:

1. Read the requested card by task ID.
2. Confirm the card is in Functional Review.
3. Confirm Code Reviewer has passed the PR.
4. Review only that task scope.
5. Add a review comment.
6. If validation fails, move Functional Review → Blocked.
7. If validation passes, move Functional Review → Ready To Release for Orchestrator approval.

---

# Orchestrator Completion Protocol

Before moving a card Review → Done, the Orchestrator Agent must:

1. Read the card.
2. Confirm reviewer output exists.
3. Confirm Ready To Release Status is PASS.
4. Confirm there are no blocker findings.
5. Move Ready To Release → Done.
6. Add final approval comment.

---

# Safety Rules

Agents must never:

- change unrelated cards
- skip status validation
- move tasks without a comment
- work on tasks not explicitly requested
- close tasks without reviewer validation
