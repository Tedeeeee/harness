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

One step must have one verification document.

## Process

1. Read the active step acceptance criteria and their evidence types
2. Gather evidence for each acceptance item using the specified method:
   - `test`: run the test command and capture the output
   - `manual`: perform the interaction and describe the observed result
   - `command`: run the CLI command and capture the output
   - `file-check`: confirm the file or artifact exists and note its path
   - if no evidence type is specified, choose the most natural method and note which type was used
3. Decide:
   - `pass`
   - `fail`
   - `blocked`
4. Write or update `docs/verification/step-xx-verification.md` for that exact step
5. Update `docs/implementation/implementation-state.md`
6. Record the verification document filename in the step-status table

## Hard Stop

Stop with `blocked` if:

- the verification basis is unclear
- required evidence cannot currently be collected
- the step cannot be judged without planner or user input

## Auto Go

If the step passes and no blocker exists:

- mark the step completed
- set `Current Status` to `done` only when no steps remain
- allow the next pending step to be activated

If the step fails:

- write the fail reason and failed acceptance items into the verification document
- set `Current Status` back to `in_progress`
- record the fail summary in the `Last Verification Result` section of implementation state
- return control to `implement-current-step` for rework
- keep the step out of `completed`

If the same step fails verification **twice consecutively**:

- classify the failure through `implementation-blocker`
- do not let the executor retry a third time without blocker classification

## Hard Rules

- do not declare pass without evidence
- do not verify against invented criteria
- do not keep coding from this skill
- do not treat `implementation-state.md` as a replacement for a verification document
- do not write `verified` or other status words into the `Verification Doc` column
- do not mark a step `completed` unless its verification document exists

## Output Shape

- a per-step verification document under `docs/verification/`
- implementation state updated using only fixed status values
- the step table updated with the actual verification document filename
- if pass and no blocker exists, execution may continue to the next step

## Common Mistakes

- treating “seems done” as completion
- mixing verification with implementation
- passing a step whose acceptance was never actually checked

## Success Condition

The harness knows, with evidence and a saved verification document, whether the current step is complete.
