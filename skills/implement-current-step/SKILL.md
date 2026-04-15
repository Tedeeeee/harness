---
name: implement-current-step
description: Use when an implementation state file points to one active step and that step's in-scope work must be implemented without crossing step boundaries.
---

# Implement Current Step

## Overview

This skill implements only the active step.

It prepares the step for verification.

It does not declare completion.

## When to Use

- `docs/implementation/implementation-state.md` exists
- exactly one step is active
- execution should continue within that step

Do **not** use this skill if verification is already ready or if the step is blocked for planning reasons.

## Read These First

- `START.md`
- active step under `docs/plans/steps/`
- `docs/implementation/implementation-state.md`
- `docs/interview/development-interview-decisions.md` when needed for confirmed decisions
- if the active step has `depends_on` entries, read those steps' `outputs` and their verification docs to understand what was already built

## Core Rule

Implement only the active step and stop at verification-ready.

## Process

1. Read the active step
2. If `depends_on` lists prior steps, read their outputs and verification docs to confirm prerequisites are met
   - if a prerequisite output is missing or its verification failed, stop and route to `implementation-blocker`
3. Check whether a verification document already exists for this step under `docs/verification/`
   - if it exists and contains a `fail` result, read the fail reason and failed acceptance items first
   - fix only the items that failed — do not redo passing items
3. Implement only in-scope work
4. Avoid out-of-scope or future-step work
5. Prepare the step to be checked against acceptance
6. Set `Current Status` to `verification-ready` when the step is ready to be checked

## Hard Stop

Stop if:

- the step cannot be completed without crossing scope
- plan and reality conflict
- product scope would need to change
- acceptance cannot be reached from the current step alone

## Auto Go

Continue if:

- decisions stay inside the active step boundary
- changes are normal implementation detail within confirmed scope

## Hard Rules

- do not implement the next step early
- do not declare `completed`
- do not silently expand product scope
- do not write verification evidence into `implementation-state.md`

## Output Shape

- code, config, or documentation changes for the active step
- an updated implementation state indicating `in_progress`, `verification-ready`, or `blocked`

## Common Mistakes

- doing adjacent-step work early
- treating likely future work as in-scope now
- claiming completion before verification

## Success Condition

The active step is ready to be checked by `verify-current-step`.
