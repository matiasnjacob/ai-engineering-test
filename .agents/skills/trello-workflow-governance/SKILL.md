---
name: trello-workflow-governance
description: Use when creating, reading, updating, commenting on, or moving Trello cards in the multi-agent workflow, including status validation, allowed transitions, card templates, and required comments.
---

# Trello Workflow Governance

Use this skill whenever Trello is the source of truth for task status.

## Core Rules

- Validate current card status before any transition.
- Add a comment for every status transition.
- Do not change unrelated cards.
- Do not skip required review gates.
- Only Orchestrator may move Ready To Release to Done.
- Developer may move Ready to In Progress and In Progress to Code Review.
- Code Reviewer may move Code Review to Functional Review or Blocked.
- Functional Reviewer may move Functional Review to Ready To Release or Blocked.

## Required References

- Read `references/trello-workflow.md` for full status, card, comment, and permission rules.
