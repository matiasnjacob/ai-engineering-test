Agent Exercise Prompts

Purpose

This document collects reusable prompts for practicing multi-agent governance with:

* Orchestrator Agent
* Developer Agent
* Reviewer Agent
* Trello MCP
* AGENTS.md
* workflow documentation

Use these prompts as starting templates. Adapt only the task ID and task context when needed.

⸻

Common Setup

Use this setup for all exercises.

Orchestrator Pane

Read:
- AGENTS.md
- /docs/workflows/trello-agent-workflow.md
You are the Orchestrator Agent.
Do not implement code.
Your responsibilities:
- clarify requirements
- create or refine Trello tasks
- wait for human approval before writing to Trello when creating new backlog items
- generate Developer handoffs by Task ID
- evaluate Reviewer findings
- create remediation tasks when needed
- move Review → Done only after Reviewer PASS
Use structured output.

Developer Pane

Read:
- AGENTS.md
- /docs/workflows/developer-validation-workflow.md
- /docs/workflows/trello-agent-workflow.md
You are the Developer Agent.
Work only on the requested Task ID.
Use Trello MCP:
1. Read the requested task card.
2. Confirm it is in Ready.
3. Move Ready → In Progress.
4. Implement only the card scope.
5. Run required validation commands when relevant.
6. Add an implementation comment to the Trello card.
7. Move In Progress → Review when finished.
Do not address unrelated tasks.
Do not create Trello cards.
Do not move tasks to Done.
Return using the Developer Output format.

Reviewer Pane

Read:
- AGENTS.md
- /docs/workflows/reviewer-workflow.md
- /docs/workflows/trello-agent-workflow.md
You are the Reviewer Agent.
Review only the requested Task ID.
Use Trello MCP:
1. Read the requested task card.
2. Confirm it is in Review.
3. Review only the card scope.
4. Validate acceptance criteria.
5. Validate architecture boundaries.
6. Run validation commands when possible.
7. Add review findings as a Trello comment.
8. If FAIL, move Review → Blocked.
9. If PASS, leave the task in Review for Orchestrator approval.
Do not modify files.
Do not create Trello cards.
Do not move tasks to Done.
Return using the Reviewer Output format.

⸻

Exercise 3 — Tiny Notes App With Trello MCP

Goal

Practice the basic end-to-end governance flow:

Human → Orchestrator → Trello Backlog → Developer → Review → Reviewer → Orchestrator → Done

Orchestrator Start Prompt

Read:
- AGENTS.md
- /docs/workflows/trello-agent-workflow.md
We are starting Exercise 3: Tiny Notes App with three agents and Trello MCP.
Do not implement code.
Your task:
1. Propose a small Trello backlog for the Tiny Notes App.
2. Use task IDs.
3. Keep tasks independently reviewable.
4. Include acceptance criteria and validation commands.
5. Wait for my approval before creating cards in Trello.
Suggested scope:
- Create backend foundation.
- Implement Note domain model.
- Implement application use cases.
- Implement in-memory repository.
- Expose Notes API endpoints.
- Add operational validation and tests.
Return:
## Understanding
...
## Questions
...
## Plan
...
## Backlog Tasks
...
## Human Approval Needed
...

Orchestrator Create Cards After Approval

The proposed backlog is approved.
Use Trello MCP to create the approved cards in Backlog.
Rules:
- Create only the approved cards.
- Use the approved Task IDs.
- Include context, task description, acceptance criteria, suggested agent, validation commands, and risk notes.
- Do not move cards to Ready yet unless I explicitly approve.
Return:
## Cards Created
...
## Human Approval Needed
...

Orchestrator Move First Task To Ready

Move task <TASK-ID> from Backlog to Ready.
Add a Trello comment explaining that the task is approved for Developer execution.
Then generate a Developer handoff that references only the Task ID.
Return:
## Task Status
...
## Developer Handoff
...

Developer Execute Task By ID

Work only on task <TASK-ID>.
Read:
- AGENTS.md
- /docs/workflows/developer-validation-workflow.md
- /docs/workflows/trello-agent-workflow.md
Use Trello MCP:
1. Read <TASK-ID>.
2. Confirm it is in Ready.
3. Move <TASK-ID> to In Progress.
4. Implement only the card scope.
5. Run relevant validation commands.
6. Add implementation notes as a Trello comment.
7. Move <TASK-ID> to Review.
Return using the Developer Output format.

Reviewer Review Task By ID

Review only task <TASK-ID>.
Read:
- AGENTS.md
- /docs/workflows/reviewer-workflow.md
- /docs/workflows/trello-agent-workflow.md
Use Trello MCP:
1. Read <TASK-ID>.
2. Confirm it is in Review.
3. Review only the task scope.
4. Validate acceptance criteria.
5. Validate architecture boundaries.
6. Run validation commands when possible.
7. Add review findings as a Trello comment.
8. If FAIL, move <TASK-ID> to Blocked.
9. If PASS, leave <TASK-ID> in Review.
Return using the Reviewer Output format.

Orchestrator Close Approved Task

Review task <TASK-ID> for final approval.
Use Trello MCP:
1. Read <TASK-ID>.
2. Confirm it is in Review.
3. Confirm Reviewer status is PASS.
4. Confirm no blocker findings remain.
5. Move <TASK-ID> from Review to Done.
6. Add final approval comment.
Return:
## Final Task Summary
...
## Decision
Done / Not Done

⸻

Exercise 4 — Failure Injection Governance

Goal

Practice governance under failure.

This exercise intentionally allows implementation mistakes so the Reviewer and Orchestrator remediation flow can be tested.

Orchestrator Start Prompt

Read:
- AGENTS.md
- /docs/workflows/trello-agent-workflow.md
We are starting Exercise 4: Failure Injection Governance.
Goal:
Test whether the governance workflow correctly detects and handles implementation failures.
Do not implement code.
Create ONE Trello task only:
FEATURE-006
Title:
Add Notes search endpoint
Requirements:
- Add a search endpoint for notes by title.
- Keep implementation intentionally lightweight.
- The endpoint may initially be implemented quickly for learning purposes.
Important:
This exercise intentionally allows implementation mistakes so the Reviewer workflow can be tested.
Your responsibilities:
1. Propose the Trello card.
2. Wait for my approval before creating it.
3. After approval, create it in Backlog.
4. Wait for approval before moving it to Ready.
5. Generate a Developer Handoff by Task ID.
Return:
## Understanding
...
## Plan
...
## Trello Task
...
## Human Approval Needed
...

Developer Failure-Injection Prompt

Work only on task FEATURE-006.
Read:
- AGENTS.md
- /docs/workflows/developer-validation-workflow.md
- /docs/workflows/trello-agent-workflow.md
Use Trello MCP:
1. Read FEATURE-006.
2. Confirm it is in Ready.
3. Move FEATURE-006 to In Progress.
4. Implement only the card scope.
5. Add implementation notes as a Trello comment.
6. Move FEATURE-006 to Review.
Additional instruction for this exercise:
Prioritize implementation speed over architectural purity.
It is acceptable for this exercise to:
- place some logic directly in the controller
- skip some validation
- avoid adding tests initially
- make small shortcuts if needed
Still keep the application working.
Do not intentionally break the build.
Return using the Developer Output format.

Reviewer Failure Detection Prompt

Read:
- AGENTS.md
- /docs/workflows/reviewer-workflow.md
- /docs/workflows/trello-agent-workflow.md
You are the Reviewer Agent.
Review only task FEATURE-006.
Use Trello MCP:
1. Read FEATURE-006.
2. Confirm it is in Review.
3. Validate architecture boundaries.
4. Validate operational evidence.
5. Validate task scope.
6. Detect governance violations.
7. Add findings as a Trello comment.
8. If validation fails, move FEATURE-006 from Review to Blocked.
Important:
This is a governance stress-test exercise.
Pay special attention to:
- business logic inside controllers
- missing tests
- missing runtime validation
- missing build/test evidence
- scope creep
- dependency violations
- inconsistent layering
Return the full Reviewer Output format.

⸻

Orchestrator Prompt — Create Bugs From Reviewer Findings

Use this after the Reviewer returns FAIL or identifies findings.

Read:
- AGENTS.md
- /docs/workflows/trello-agent-workflow.md
- /docs/workflows/reviewer-workflow.md
Read the Reviewer findings for task <TASK-ID>.
Do not implement fixes.
Do not modify source files.
Your task:
1. Analyze the Reviewer findings.
2. Convert actionable findings into remediation Trello cards.
3. Create BUG cards for defects.
4. Create MEDIUM or LOW cards for non-defect improvements.
5. Keep each card independently reviewable.
6. Include acceptance criteria and validation commands.
7. Link each remediation card back to source task <TASK-ID>.
8. Wait for my approval before moving remediation cards to Ready.
Rules:
- One card per actionable issue.
- Do not create duplicate cards.
- Do not create cards for accepted risks unless explicitly requested.
- Do not create cards for observations that are not actionable.
- Do not move <TASK-ID> to Done.
Card ID guidance:
- BUG-### for behavior defects or architecture violations.
- MEDIUM-### for validation gaps, test gaps, or maintainability issues.
- LOW-### for cleanup, naming, or documentation gaps.
Return:
## Findings Analysis
...
## Remediation Cards Proposed
For each card:
- Task ID:
- Title:
- Priority:
- Source Finding:
- Description:
- Acceptance Criteria:
- Validation Commands:
- Suggested Agent:
- Notes for Developer:
## Suggested Execution Order
...
## Human Approval Needed
...

Orchestrator Prompt — Create Approved Remediation Cards

The remediation cards are approved.
Use Trello MCP to create the approved remediation cards in Backlog.
Rules:
- Create only approved cards.
- Preserve the approved Task IDs and titles.
- Include the source task ID <TASK-ID> in every card.
- Include acceptance criteria and validation commands.
- Do not move cards to Ready yet unless I explicitly approve.
Return:
## Cards Created
...
## Human Approval Needed
...

⸻

Exercise 5 — Multi-Task Coordination

Goal

Practice orchestrating multiple tasks with dependencies, priorities, and task states.

The Orchestrator must coordinate several cards without losing scope or status control.

Orchestrator Start Prompt

Read:
- AGENTS.md
- /docs/workflows/trello-agent-workflow.md
We are starting Exercise 5: Multi-Task Coordination.
Goal:
Coordinate multiple Tiny Notes App tasks through Trello while preserving governance rules.
Do not implement code.
Your task:
1. Inspect current Trello board state.
2. Identify existing cards related to Tiny Notes App.
3. Group cards by status.
4. Identify dependencies between cards.
5. Recommend the next 2 or 3 cards to execute.
6. Do not move any card without my approval.
Return:
## Board Understanding
...
## Current Work In Progress
...
## Dependencies
...
## Recommended Next Tasks
...
## Risks
...
## Human Approval Needed
...

Orchestrator Prioritize Ready Work

Based on the approved execution order, move the next approved task(s) from Backlog to Ready.
Use Trello MCP.
Rules:
- Move only approved tasks.
- Add a Trello comment explaining why each task is ready.
- Do not move more than 2 tasks to Ready unless I explicitly approve.
- Do not move blocked tasks.
- Do not move tasks with unresolved dependencies.
Return:
## Tasks Moved To Ready
...
## Developer Handoffs
...

Developer Execute One Task In Multi-Task Context

Work only on task <TASK-ID>.
Read:
- AGENTS.md
- /docs/workflows/developer-validation-workflow.md
- /docs/workflows/trello-agent-workflow.md
Use Trello MCP:
1. Read <TASK-ID>.
2. Confirm it is in Ready.
3. Check whether the card has dependencies.
4. If dependencies are unresolved, stop and report.
5. Move <TASK-ID> to In Progress.
6. Implement only this task scope.
7. Run relevant validation commands.
8. Add implementation notes as a Trello comment.
9. Move <TASK-ID> to Review.
Do not work on other Ready cards.
Do not batch unrelated tasks.
Return using the Developer Output format.

Reviewer Review One Task In Multi-Task Context

Review only task <TASK-ID>.
Read:
- AGENTS.md
- /docs/workflows/reviewer-workflow.md
- /docs/workflows/trello-agent-workflow.md
Use Trello MCP:
1. Read <TASK-ID>.
2. Confirm it is in Review.
3. Check source task, dependencies, and acceptance criteria.
4. Review only this task scope.
5. Validate architecture and operational evidence.
6. Add findings as a Trello comment.
7. If FAIL, move <TASK-ID> to Blocked.
8. If PASS, leave <TASK-ID> in Review.
Return using the Reviewer Output format.

⸻

Exercise 6 — Human Escalation Rules

Goal

Practice when agents must stop and escalate instead of improvising.

Orchestrator Start Prompt

Read:
- AGENTS.md
- /docs/workflows/trello-agent-workflow.md
We are starting Exercise 6: Human Escalation Rules.
Goal:
Define when agents must stop and escalate to the human supervisor.
Do not implement code.
Your task:
1. Review current AGENTS.md and workflow docs.
2. Propose escalation rules for Orchestrator, Developer, and Reviewer.
3. Propose where these rules should live.
4. Create Trello cards only after human approval.
Return:
## Escalation Rule Proposal
...
## Suggested Documentation Updates
...
## Backlog Tasks
...
## Human Approval Needed
...

⸻

Exercise 7 — Reviewer Severity Calibration

Goal

Practice consistent severity classification.

Orchestrator Start Prompt

Read:
- AGENTS.md
- /docs/workflows/reviewer-workflow.md
- /docs/workflows/trello-agent-workflow.md
We are starting Exercise 7: Reviewer Severity Calibration.
Goal:
Improve how the Reviewer classifies BLOCKER, MEDIUM, and LOW findings.
Do not implement code.
Your task:
1. Review recent Reviewer findings.
2. Identify inconsistent or unclear severity decisions.
3. Propose calibration examples.
4. Propose documentation updates.
5. Create Trello cards only after human approval.
Return:
## Severity Calibration Analysis
...
## Calibration Examples
...
## Documentation Updates Proposed
...
## Human Approval Needed
...

⸻

Exercise 8 — Definition of Done Evolution

Goal

Evolve Definition of Done without making it too heavy.

Orchestrator Start Prompt

Read:
- AGENTS.md
- /docs/workflows/developer-validation-workflow.md
- /docs/workflows/reviewer-workflow.md
- /docs/workflows/trello-agent-workflow.md
We are starting Exercise 8: Definition of Done Evolution.
Goal:
Improve the Definition of Done based on completed Tiny Notes App tasks and reviewer findings.
Do not implement code.
Your task:
1. Analyze recent completed tasks.
2. Identify recurring validation gaps.
3. Propose DoD improvements.
4. Keep DoD practical and lightweight.
5. Create documentation update tasks only after human approval.
Return:
## Current DoD Gaps
...
## Proposed DoD Updates
...
## Risks Of Overengineering
...
## Backlog Tasks Proposed
...
## Human Approval Needed
...

⸻

Quick Task-ID Prompts

Ask Orchestrator For Next Task

Read AGENTS.md and Trello workflow.
Inspect the current Trello board.
Recommend the next single task to execute.
Do not move anything without my approval.
Return:
## Recommendation
...
## Reasoning
...
## Human Approval Needed
...

Ask Developer To Execute Task

Execute task <TASK-ID> according to AGENTS.md and Trello workflow.
Work only on that task.
Read the Trello card before acting.
Move Ready → In Progress.
Move In Progress → Review when complete.
Return Developer Output format.

Ask Reviewer To Review Task

Review task <TASK-ID> according to AGENTS.md and Reviewer workflow.
Read the Trello card before acting.
Confirm it is in Review.
Do not modify files.
If FAIL, move Review → Blocked.
If PASS, leave in Review for Orchestrator approval.
Return Reviewer Output format.

Ask Orchestrator To Close Task

Finalize task <TASK-ID>.
Read the Trello card.
Confirm Reviewer PASS exists.
Confirm no blockers remain.
Move Review → Done.
Add final approval comment.
Return final task summary.