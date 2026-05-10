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
- Review
- Blocked
- Done

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
- move Review → Done
- move any task → Blocked
- create remediation tasks from reviewer findings

Must NOT:

- implement tasks
- mark work Done without reviewer validation

## Developer Agent

May:

- read assigned task cards
- move Ready → In Progress
- move In Progress → Review
- add implementation comments

Must NOT:

- create cards
- close cards
- move cards to Done
- modify unrelated cards

## Reviewer Agent

May:

- read cards in Review
- add review comments
- move Review → Blocked if validation fails

Must NOT:

- create cards
- implement fixes
- move cards to Done

---

# Status Transition Rules

Allowed transitions:

| Agent | From | To |
|---|---|---|
| Orchestrator | Backlog | Ready |
| Orchestrator | Review | Done |
| Orchestrator | Any | Blocked |
| Developer | Ready | In Progress |
| Developer | In Progress | Review |
| Reviewer | Review | Blocked |

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
Developer / Reviewer / Orchestrator

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
6. Move the card to Review when finished.
7. Add a final implementation comment.

If the card is not in Ready, the Developer Agent must stop.

---

# Reviewer Start Protocol

Before reviewing a Trello task, the Reviewer Agent must:

1. Read the requested card by task ID.
2. Confirm the card is in Review.
3. Review only that task scope.
4. Add a review comment.
5. If validation fails, move Review → Blocked.
6. If validation passes, leave the task in Review for Orchestrator approval.

---

# Orchestrator Completion Protocol

Before moving a card Review → Done, the Orchestrator Agent must:

1. Read the card.
2. Confirm reviewer output exists.
3. Confirm Review Status is PASS.
4. Confirm there are no blocker findings.
5. Move Review → Done.
6. Add final approval comment.

---

# Safety Rules

Agents must never:

- change unrelated cards
- skip status validation
- move tasks without a comment
- work on tasks not explicitly requested
- close tasks without reviewer validation