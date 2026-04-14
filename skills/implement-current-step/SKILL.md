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

## Core Rule

Implement only the active step and stop at verification-ready.

## Process

1. Read the active step
2. Implement only in-scope work
3. Avoid out-of-scope or future-step work
4. Prepare the step to be checked against acceptance
5. Set `Current Status` to `verification-ready` when the step is ready to be checked

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
