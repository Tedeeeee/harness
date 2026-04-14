# State Model

This document defines the minimum state documents required for the harness to operate safely.

## Documents

### Requirements

- Purpose: fixed human-authored product input
- Location: `docs/requirements/*.md`
- Rule: AI must not rewrite the original file

### Interview Decisions

- Purpose: confirmed planning decisions gathered through questions
- Location: `docs/interview/development-interview-decisions.md`
- Rule: use `confirmed` only for explicit user answers or approvals

### Master Plan

- Purpose: overall implementation structure derived from confirmed decisions
- Location: `docs/plans/master-plan.md`
- Rule: planning is downstream from the interview

### Step Docs

- Purpose: execution units with scope and acceptance
- Location: `docs/plans/steps/*.md`
- Rule: each step must define in-scope, out-of-scope, outputs, and acceptance

### Implementation State

- Purpose: record which step is active and what the next allowed action is
- Location: `docs/implementation/implementation-state.md`
- Rule: exactly one active step at a time

### Verification Docs

- Purpose: evidence-based completion records
- Location: `docs/verification/step-xx-verification.md`
- Rule: no completed state without verification evidence

## Design Principle

Prompt gives direction.

Skills give behavior.

Documents give state.
