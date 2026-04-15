---
name: project-retrospective
description: Use when all steps are completed and implementation state is done, to review the project and extract reusable lessons into memory before closing.
---

# Project Retrospective

## Overview

This skill reviews a completed project and extracts reusable knowledge into memory.

It does not start new work.

It closes the learning loop so the next project benefits from this one.

## When to Use

- `docs/implementation/implementation-state.md` shows `Current Status: done`
- all steps are `completed` with verification docs
- the project has not yet been reviewed

Do **not** use this skill while steps are still active or pending.

## Read These First

- `docs/implementation/implementation-state.md`
- all verification docs under `docs/verification/`
- `docs/interview/development-interview-decisions.md`
- `docs/plans/master-plan.md`
- `docs/plans/steps/*.md`
- `memory/project-memory.md`
- `memory/harness-memory.md`

## Core Rule

Extract only what was confirmed or repeated. Do not save guesses or one-time incidents.

## Process

1. Scan all verification docs for fail or blocked results
   - note which steps had rework and why
2. Scan interview decisions for patterns
   - which tech choices were made and confirmed
   - which decisions came up repeatedly across projects
3. Scan step docs for sizing and dependency patterns
   - were steps well-sized or did they need splitting/merging
   - were dependencies accurate or did executor hit surprises
4. Classify findings into three buckets:
   - **project-memory**: tech conventions, repeated decisions, repeated blockers specific to this project type
   - **harness-memory**: harness operation rules or preferences that should apply to all future projects
   - **discard**: one-time facts, already-fixed issues, things derivable from code
5. Update `memory/project-memory.md` with project-memory items
6. Update `memory/harness-memory.md` only if a new stable pattern was confirmed
7. Do not duplicate what is already in memory

## What to Extract

Save if:

- a tech choice was confirmed and is likely to recur (e.g. "SQLite for local-only apps")
- a blocker pattern repeated (e.g. "Windows path issues with PowerShell hooks")
- a step sizing lesson was learned (e.g. "UI steps should split list view and form into separate steps")
- an interview question was always asked and could become a default next time
- a harness workflow surprised the user or needed manual correction

## What NOT to Extract

Do not save:

- implementation details derivable from the code
- one-time bugs that were fixed
- git history or commit summaries
- anything already documented in existing memory

## Hard Rules

- do not modify any implementation, plan, or verification documents
- do not start new planning or execution
- do not save speculative lessons — only confirmed or repeated patterns
- do not overwrite existing memory entries — update or append
- always check existing memory before writing to avoid duplicates

## Output Shape

- a summary of findings presented to the user
- updated `memory/project-memory.md` if project-specific lessons exist
- updated `memory/harness-memory.md` if harness-level lessons exist
- a clear statement that the project review is complete

## Common Mistakes

- saving everything instead of filtering for reusable patterns
- treating one-time debugging sessions as repeatable lessons
- writing memory entries that duplicate existing ones
- skipping the review and jumping to the next project

## Success Condition

Memory is updated with confirmed, reusable lessons. The next project's planner and interviewer can benefit from this project's experience.
