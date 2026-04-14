---
name: generate-master-plan
description: Use when the development interview has produced enough confirmed decisions to structure a full implementation plan, but no master plan exists yet.
---

# Generate Master Plan

## Overview

This skill structures confirmed decisions into an overall implementation path.

It organizes work.

It does not invent new confirmed scope.

## When to Use

- interview exit criteria are satisfied
- confirmed planning decisions already exist
- `docs/plans/master-plan.md` does not exist yet, or must be created from confirmed decisions

Do **not** use this skill while planning is still blocked by unanswered questions.

## Read These First

- `START.md`
- `docs/state-model.md`
- latest file under `docs/requirements/`
- `docs/interview/development-interview-decisions.md`
- `templates/master-plan-template.md`

## Core Rule

Planning is downstream from confirmed decisions.

This skill structures decisions into a plan.

It does not replace the interview.

## Process

1. Read requirements and interview decisions
2. Extract confirmed scope and confirmed development rules
3. Define the overall execution direction
4. Write milestones and completion definition
5. Write `docs/plans/master-plan.md`

## Hard Stop

Stop if:

- key interview decisions are still unresolved
- plan completion criteria would be guessed
- product scope would need to be expanded silently

## Auto Go

Continue if:

- confirmed decisions are enough to define milestones
- local execution, testing, and documentation expectations are clear enough

## Hard Rules

- do not promote `open` or `proposed` items to `confirmed`
- do not silently add new product scope
- do not weaken completion criteria
- do not create step docs from this skill

## Output Shape

- `docs/plans/master-plan.md`
- a clear handoff to `generate-step-docs`

## Common Mistakes

- writing the plan too early
- mixing guessed scope into confirmed scope
- turning the plan into a second interview

## Success Condition

An overall implementation structure exists that reflects confirmed decisions and supports step decomposition.
