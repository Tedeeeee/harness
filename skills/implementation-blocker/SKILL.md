---
name: implementation-blocker
description: Use when execution or verification cannot continue normally and the harness must classify whether the issue belongs to implementation, planning, scope, or external conditions.
---

# Implementation Blocker

## Overview

This skill classifies a blocked situation.

It decides whether execution should:

- keep fixing inside the current step
- return to planning
- request user input through planner logic

## When to Use

- executor cannot continue safely
- verifier returns `blocked`
- implementation and plan appear to conflict

## Read These First

- `START.md`
- active step doc
- `docs/implementation/implementation-state.md`
- `docs/interview/development-interview-decisions.md`
- `docs/plans/master-plan.md`

## Core Rule

Executor should not negotiate scope directly with the user.

Blocked work must be classified first.

## Process

1. Inspect the blocker
2. Classify it as one of:
   - implementation detail issue
   - plan conflict
   - scope change
   - external environment issue
3. Decide the next owner:
   - executor
   - planner
   - user input through planner
4. Update implementation state with the blocker record

## Hard Stop

Stop and route away from executor if:

- product scope must change
- confirmed plan boundaries no longer match reality
- user approval is required

## Auto Go

Let executor continue if:

- the blocker is only a local implementation detail
- the active step can still be completed without changing scope or plan meaning

## Hard Rules

- do not let executor silently absorb product-scope decisions
- do not hide plan conflicts as “implementation detail”

## Output Shape

- blocker classification
- recommended owner for next action
- implementation state updated with blocker notes

## Success Condition

The harness knows whether to keep implementing, return to planning, or request user input.
