---
name: author-product-requirements
description: Use when no requirements document exists yet and the harness needs to turn either a rough user idea or a completed visual-source analysis into a structured product requirements draft before planning.
---

# Author Product Requirements

## Overview

This skill turns raw input into a structured requirements draft.

It does not choose implementation details, create plans, or start coding.

## When to Use

- `docs/requirements/` does not yet contain the active requirements document
- The user has only provided a rough idea, short prompt, or loosely structured request
- A visual analysis document already exists and must be promoted into requirements
- Planning cannot begin safely without a structured requirements file

Do not use this skill if a current requirements document already exists and is still the source of truth.

## Read These First

- `CLAUDE.md`
- `templates/product-requirements-template.md`
- `docs/visual-analysis/visual-source-analysis.md` if it exists
- `memory/project-memory.md` if it contains reusable defaults that do not change scope

## Core Rule

Requirements authoring is a promotion step, not an invention step.

If the input is visual, promote the recorded screen inventory into explicit requirements instead of re-interpreting the PDF from scratch.

## Closure Metadata Rule

- Always set `Status: draft` when creating a new requirements file
- Leave `Confirmed By` and `Confirmed At` empty at authoring time
- Set `Linked Planning State` to the relative path of `docs/plans/planning-state.md` (create the path value even if the planning state file does not yet exist — the planner stage will create it)
- Do not set `Status: confirmed` in this skill. Only `assess-product-requirements` performs that transition after user approval.

## Process

1. Read the user's direct request
2. If `docs/visual-analysis/visual-source-analysis.md` exists, treat it as fixed input
3. Fill the requirements template using only supported input:
   - Metadata (see closure rule below)
   - Goal
   - Problem
   - Users
   - Core Features
   - Out of Scope
   - Constraints
   - Success Criteria
   - Input Sources
   - Screen Coverage
4. Turn every included screen from the visual analysis into explicit scope or success criteria
5. Preserve explicit exclusions from the visual analysis instead of silently re-including them
6. Keep unresolved items as `[undecided]`
7. Show the full draft to the user
8. Ask for `confirm`, `modify`, or `reject`
9. Save the confirmed document to `docs/requirements/{project-name}.md`
10. Hand off to `assess-product-requirements`

## Hard Stop

Stop and wait for the user if:

- The visual analysis still contains unresolved scope ambiguity
- The user rejects the draft
- Creating the draft would require silently adding or removing screens

## Auto Go

Continue when:

- The draft can be written directly from the user's input or the visual analysis
- Remaining uncertainty is small enough to mark as `[undecided]`
- The user confirms the draft or requests straightforward edits

## Strong Rules

- Do not choose a tech stack here
- Do not create planning or implementation documents here
- Do not silently drop an included screen from the visual analysis
- Do not treat a guessed exclusion as user approval
- A received file is human-authored input
- Never write `Status: confirmed` from this skill

## Output

- A complete requirements draft using `templates/product-requirements-template.md`
- A clear request for `confirm`, `modify`, or `reject`
- After confirmation, a saved requirements file and handoff to `assess-product-requirements`

## Success Condition

`docs/requirements/` contains a confirmed requirements document strong enough to enter requirements assessment without silently shrinking the original request.
