---
name: verify-current-step
description: Use when the active implementation step is ready to be checked against its acceptance criteria and completion must be decided from evidence rather than assertion.
---

# Verify Current Step

## Overview

This skill decides whether the active step has actually been completed.

It produces evidence.

It does not continue implementation work itself.

## When to Use

- an active step exists
- implementation is verification-ready
- the harness needs a pass, fail, or blocked outcome

Do **not** use this skill before the current step has been implemented.

## Read These First

- `START.md`
- active step under `docs/plans/steps/`
- `docs/implementation/implementation-state.md`
- `templates/step-verification-template.md`

## Core Rule

No evidence, no pass.

## Process

1. Read the active step acceptance criteria
2. Gather evidence for each acceptance item
3. Decide:
   - `pass`
   - `fail`
   - `blocked`
4. Write a verification document under `docs/verification/`
5. Update implementation state accordingly

## Hard Stop

Stop with `blocked` if:

- the verification basis is unclear
- required evidence cannot currently be collected
- the step cannot be judged without planner or user input

## Auto Go

If the step passes and no blocker exists:

- mark the step completed
- allow the next pending step to be activated

If the step fails:

- return control to execution for fixes

## Hard Rules

- do not declare pass without evidence
- do not verify against invented criteria
- do not keep coding from this skill

## Output Shape

- a verification document
- implementation state updated to `completed`, `in_progress`, or `blocked`
- if pass and no blocker exists, execution may continue to the next step

## Common Mistakes

- treating “seems done” as completion
- mixing verification with implementation
- passing a step whose acceptance was never actually checked

## Success Condition

The harness knows, with evidence, whether the current step is complete.
