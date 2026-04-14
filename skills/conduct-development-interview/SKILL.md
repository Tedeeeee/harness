---
name: conduct-development-interview
description: Use when product requirements are sufficient to begin planning, but key development decisions are still missing and must be collected through one-question-at-a-time user interaction.
---

# Conduct Development Interview

## Overview

This skill fills the planning-critical gaps that remain after requirements assessment.

It collects confirmed decisions.

It does not write the implementation plan yet.

## When to Use

- requirements are sufficient to begin planning
- key development decisions are still missing
- planner must ask questions before plan generation can safely begin

Do **not** use this skill after the interview exit criteria are already satisfied.

## Read These First

- `START.md`
- `docs/state-model.md`
- `docs/document-lifecycle.md`
- latest file under `docs/requirements/`
- `templates/development-interview-decisions-template.md`

## Core Rule

Ask exactly one planning-critical question at a time.

Record only explicit user answers or approvals as `confirmed`.

## Process

1. Read the current requirements document
2. Identify the single most important planning gap
3. Ask exactly one question
4. Include options `1`, `2`, `3`, and `4. user direction`
5. Record the result in `docs/interview/development-interview-decisions.md`
6. Repeat until planning is no longer blocked

## Interview Exit Criteria

The interview may end only when:

- key tech choices are decided
- test expectations are decided
- documentation scope is decided
- unresolved items no longer block implementation planning

## Hard Stop

Stop and ask the user if:

- product scope would change
- a decision would be marked `confirmed` without explicit approval
- a planning-critical gap still prevents safe plan generation

## Auto Go

Continue the interview if:

- the next missing item can be resolved with one question
- the current decision falls within planning detail rather than product scope

## Hard Rules

- ask one question only
- do not batch questions
- do not mark guesses as `confirmed`
- do not create plan documents from this skill
- if AI first raises a missing item and the user approves it, record that as `ai-raised-approved-by-user`

## Output Shape

- one question with options `1`, `2`, `3`, and `4`
- or an updated interview decisions document plus a clear handoff to `generate-master-plan`

## Common Mistakes

- turning the interview into a plan
- asking multiple questions in one message
- recording inferred answers as confirmed
- treating implementation detail as product scope by default

## Success Condition

Planning can begin without relying on unapproved assumptions.
