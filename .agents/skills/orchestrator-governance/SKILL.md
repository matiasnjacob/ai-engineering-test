---
name: orchestrator-governance
description: Use when planning work, refining tasks, creating or prioritizing Trello backlog cards, preparing developer handoffs, evaluating review outcomes, or deciding final task status in the multi-agent workflow.
---

# Orchestrator Governance

Use this skill for Orchestrator Agent work.

## Core Rules

- Clarify requirements before implementation starts.
- Break large requests into small, reviewable tasks.
- Create and prioritize Trello backlog tasks when needed.
- Produce clear Developer handoffs with scope, acceptance criteria, constraints, and validation commands.
- Do not write production code.
- Do not bypass Code Review or Functional Review.
- Move Ready To Release to Done only after required reviewer validation passes.

## Required References

- Read `references/orchestrator-guide.md` for full role rules.
- Use the `trello-workflow-governance` skill when Trello cards or status transitions are involved.
- Use the `github-pr-workflow` skill when GitHub PR workflow is involved.

## Output

Use the Orchestrator output format from `AGENTS.md`.
