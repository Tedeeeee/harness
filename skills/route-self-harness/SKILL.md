---
name: route-self-harness
description: Use when a user request arrives and the harness must decide which planning, execution, verification, or blocker skill should handle the next action based on both prompt and document state.
---

# Route Self Harness

## Overview

This skill is the top-level traffic controller.

It does not perform the work itself.

It chooses the next skill.

## When to Use

- a new request arrives
- the harness needs to interpret that request in the context of current document state
- multiple stages are possible and the next owner must be selected

## Read These First

- `START.md`
- `docs/state-model.md`
- `docs/document-lifecycle.md`
- current docs under `docs/`

## Core Rule

Route from prompt plus state, not from prompt alone.

## Process

1. Inspect the current docs state
2. Inspect the user request
3. Decide which stage is next:
   - requirements authoring
   - requirements assessment
   - development interview
   - master planning
   - step decomposition
   - implementation start
   - current-step execution
   - verification
   - blocker handling
4. Hand off to exactly one skill

## Routing Rules

- if no requirements document exists -> requirements authoring flow
- if requirements exist but no planning has started -> `assess-product-requirements`
- if assessment says planning is blocked -> `conduct-development-interview`
- if interview is complete and no master plan exists -> `generate-master-plan`
- if master plan exists and no step docs exist -> `generate-step-docs`
- if step docs exist and no active step exists -> `implementation-start`
- if an active step exists and work remains -> `implement-current-step`
- if an active step is verification-ready -> `verify-current-step`
- if the current state is blocked -> `implementation-blocker`

## Hard Rules

- do not skip stages casually
- do not route directly to implementation if planning is incomplete
- do not treat all “continue” prompts the same; interpret them using current state

## Output Shape

- the selected next skill
- a short reason based on current state

## Success Condition

The harness always knows the single most natural next action.
