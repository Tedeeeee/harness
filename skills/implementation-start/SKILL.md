---
name: implementation-start
description: Use when step documents already exist and execution must choose exactly one active step to begin or continue step-gated implementation.
---

# Implementation Start

## Overview

This skill selects the active execution step.

It turns a written step plan into a single current step for execution.

## When to Use

- step docs exist
- no active step is currently set
- execution is about to begin or resume

Do **not** use this skill when an active step is already in progress unless you are recovering state.

## Read These First

- `START.md`
- `docs/plans/master-plan.md`
- `docs/plans/steps/*.md`
- `templates/implementation-state-template.md`

## Core Rule

Exactly one step may be active at a time.

## Process

1. Read the step docs in dependency order
2. Find the first pending step that is allowed to begin
3. Create or update `docs/implementation/implementation-state.md`
4. Mark that step as the current active step

## Hard Stop

Stop if:

- step dependencies are unclear
- more than one step appears active
- no pending step can be safely activated

## Auto Go

Continue if:

- the next allowed step is clear from the step docs

## Hard Rules

- do not activate multiple steps
- do not skip a blocking dependency
- do not implement code from this skill

## Output Shape

- updated `docs/implementation/implementation-state.md`
- a clear handoff to `implement-current-step`

## Success Condition

Execution knows exactly which step is active and what work may begin next.
