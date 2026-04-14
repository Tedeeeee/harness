---
name: generate-step-docs
description: Use when a master plan exists and must be decomposed into step-gated execution units with clear scope, outputs, and acceptance criteria.
---

# Generate Step Docs

## Overview

This skill decomposes the master plan into executable step units.

Each step must be clear enough for executor and verifier to use without guessing.

## When to Use

- `docs/plans/master-plan.md` exists
- execution needs step-gated boundaries
- `docs/plans/steps/*.md` must be created or rewritten from the current master plan

Do **not** use this skill before the master plan is stable.

## Read These First

- `START.md`
- `docs/plans/master-plan.md`
- `docs/interview/development-interview-decisions.md`
- `templates/step-template.md`

## Core Rule

Each step must define exactly what belongs here, what does not belong here, and how completion will be checked.

## Process

1. Read the master plan
2. Identify natural execution boundaries
3. Create one step document per boundary
4. For each step, define:
   - in-scope work
   - out-of-scope work
   - outputs
   - acceptance
   - dependencies
5. Write the step documents under `docs/plans/steps/`

## Hard Stop

Stop if:

- the master plan is not stable enough to decompose
- step acceptance would have to be invented without basis
- step boundaries are too ambiguous to support gated execution

## Auto Go

Continue if:

- the master plan clearly implies step boundaries
- acceptance can be tied back to confirmed plan scope

## Hard Rules

- do not create overlapping steps casually
- do not put next-step work into the current step
- do not write acceptance with no execution basis

## Output Shape

- one or more files under `docs/plans/steps/`
- a clear note that execution may begin with `implementation-start`

## Common Mistakes

- steps that are too large
- steps that hide out-of-scope boundaries
- acceptance criteria that are too vague to verify

## Success Condition

The project can now be executed step-by-step without free-running across the whole plan.
