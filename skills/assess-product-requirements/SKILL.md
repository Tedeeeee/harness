---
name: assess-product-requirements
description: Use when a human-authored requirements markdown file exists and you need to decide whether planning can safely begin or one blocking question must be asked first.
---

# Assess Product Requirements

## Overview

This skill is the first planner gate.

It reads the human-authored requirements document and decides whether planning can move forward safely.

It does **not** write plans.

## When to Use

- a requirements markdown file already exists under `docs/requirements/`
- the harness must decide whether to continue into planning
- you need to know whether to ask one blocking question or proceed to the development interview

Do **not** use this skill when no requirements document exists yet.

## Read These First

- `START.md`
- `docs/state-model.md`
- `docs/document-lifecycle.md`
- `docs/requirements/`

## Core Rule

This skill answers only one question:

`Can planning continue safely from the current requirements?`

If the answer is no, stop and ask exactly one blocking question.

If the answer is yes, hand off to the development interview.

## Process

1. Select the newest human-authored requirements markdown file under `docs/requirements/`
   - ignore `README.md`
   - ignore dotfiles such as `.gitkeep`
2. Read the document as fixed human input
3. Check whether the document provides enough planning ground for:
   - goal
   - problem
   - users
   - core features
   - out of scope
   - constraints
   - success criteria
4. Apply the planner gate:
   - if planning would rely on guesses about product scope, stop
   - if planning would lack enough basis to write step acceptance, stop
   - otherwise continue
5. Return exactly one of:
   - `sufficient -> continue to development interview`
   - `insufficient -> ask one blocking question`

## Hard Stop

Stop and ask a question if:

- product scope would have to be guessed
- a key planning decision is missing and blocks safe interviewing
- the current requirements would force later plan documents to invent acceptance criteria

## Auto Go

Continue to the next planner stage if:

- the document is enough to begin the development interview
- the missing details can be collected through normal interview questions later

## Hard Rules

- Do not rewrite the requirements document
- Do not enrich the requirements in place
- Do not create `docs/interview/`, `docs/plans/`, or implementation documents from this skill
- Do not ask a batch of questions
- Ask only the single highest-priority blocking question if the requirements are insufficient

## Output Shape

### If sufficient

- identify the selected requirements file
- state that the requirements are sufficient to begin the development interview
- name the next skill: `conduct-development-interview`

### If insufficient

- identify the selected requirements file
- state that the requirements are not yet sufficient
- ask exactly one blocking question

## Common Mistakes

- Turning a sufficiency check into an implementation plan
- Rewriting the requirements instead of treating them as fixed input
- Asking multiple questions at once
- Treating missing implementation details as if they always block planning

## Success Condition

The harness can clearly decide whether to:

- continue into the development interview, or
- stop with one blocking question
