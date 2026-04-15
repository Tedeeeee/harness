---
name: author-product-requirements
description: Use when no requirements document exists and a user has provided a brief idea or one-liner that must be turned into a structured requirements draft for confirmation.
---

# Author Product Requirements

## Overview

This skill turns a brief user idea into a structured requirements draft.

It does not make development decisions.

It does not start planning.

## When to Use

- no requirements document exists under `docs/requirements/`
- the user has expressed what they want to build in an informal or minimal form
- a structured requirements document is needed before planning can begin

Do **not** use this skill if a requirements document already exists.

## Read These First

- `START.md`
- `templates/product-requirements-template.md`
- `memory/project-memory.md` for any reusable context from prior projects

## Core Rule

Draft the big picture. Do not decide how to build it.

## Process

1. Read the user's idea
2. Fill out the template structure with what can be reasonably inferred:
   - Goal
   - Problem
   - Users
   - Core Features
   - Out of Scope
   - Constraints
   - Success Criteria
3. For anything that cannot be inferred from the user's input, write `[undecided]`
4. Present the full draft to the user in a single message
5. Ask the user to confirm, modify, or reject the draft
6. Save the confirmed version to `docs/requirements/{project-name}.md`
7. Hand off to `assess-product-requirements`

## Hard Stop

Stop and wait for user input if:

- the idea is too vague to fill even Goal and Core Features
- the user rejects the draft and asks for changes
- the draft would require guessing product scope beyond what the user stated

## Auto Go

Continue if:

- the user confirms the draft as-is
- the user provides modifications and you can apply them immediately

## Hard Rules

- present the draft once, not section by section
- do not invent features the user did not mention or imply
- do not make technology choices — that belongs to the development interview
- do not create interview, plan, or implementation documents from this skill
- mark genuinely unknown sections as `[undecided]`, not with plausible guesses
- the saved file is treated as human-authored input from the moment it is confirmed

## Output Shape

- a full requirements draft formatted per `templates/product-requirements-template.md`
- a clear ask: confirm, modify, or reject
- after confirmation: the saved file path and handoff to `assess-product-requirements`

## Common Mistakes

- guessing features the user never mentioned
- choosing tech stack or architecture in the requirements
- asking multiple rounds of questions instead of drafting once
- skipping user confirmation and saving directly
- filling `[undecided]` with plausible-sounding assumptions

## Success Condition

A confirmed, human-approved requirements document exists under `docs/requirements/` and the harness can proceed to assessment.
