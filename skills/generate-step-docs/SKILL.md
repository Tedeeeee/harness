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

## Step Sizing Guide

A well-sized step:

- can be implemented and verified within a single session
- touches one logical layer or concern (e.g. DB schema, API, UI, styling)
- has 2–5 acceptance criteria — fewer means the step is too vague, more means it should be split
- produces outputs that can be tested independently from later steps

Target range: **3–7 steps** for a typical small-to-medium project.

If the plan produces more than 10 steps, look for steps that can be merged without losing verification clarity. If it produces fewer than 2 steps, look for natural split points within each step.

## Process

1. Read the master plan
2. Identify natural execution boundaries using the sizing guide above
3. Create one step document per boundary
4. For each step, define:
   - in-scope work
   - out-of-scope work
   - outputs: concrete artifacts this step produces (files, tables, endpoints, components)
   - acceptance: observable checks that prove the outputs work, each paired with an evidence type (`test`, `manual`, `command`, or `file-check`)
   - `depends_on`: list prior step IDs whose outputs this step requires as input
     - only list direct dependencies, not the full chain
     - if a step has no dependencies, use `[]`
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
- every step's `outputs` must be specific enough for the next step's executor to locate them
- `depends_on` must reflect real input needs, not just ordering preference

## Output Shape

- one or more files under `docs/plans/steps/`
- a clear note that execution may begin with `implementation-start`

## Common Mistakes

- steps that are too large to implement and verify in one session
- steps that are too small and create unnecessary overhead
- steps that hide out-of-scope boundaries
- acceptance criteria that are too vague to verify

## Success Condition

The project can now be executed step-by-step without free-running across the whole plan.
