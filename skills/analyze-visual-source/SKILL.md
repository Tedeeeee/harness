---
name: analyze-visual-source
description: Use when the user provides a PDF, image set, wireframe, prototype, screenshot collection, or other visual source of truth that must be converted into a structured screen analysis before requirements authoring or planning.
---

# Analyze Visual Source

## Overview

This skill turns a visual source into a structured analysis document.

It exists to stop the harness from skipping directly from a PDF or mockup to requirements while silently dropping screens, links, or flows.

## When to Use

- The main input is visual rather than a full text requirements document
- The user wants the final UI to match a PDF, wireframe, screenshot set, or prototype
- The harness needs to know which screens actually exist before writing requirements

Do not use this skill when a complete text requirements document is already the primary source of truth and the visual asset is only loose inspiration.

## Read These First

- `CLAUDE.md`
- `templates/visual-source-analysis-template.md`
- Existing files in `docs/visual-analysis/`

## Core Rule

Never promote a visual source directly into implementation scope.

First create a screen inventory, record exclusions, and surface ambiguity.

## Process

1. Read the visual source itself
2. Identify every distinct screen, view, or navigable state visible in the source
3. Record each screen with:
   - id (`V-NN`, unique, never reused)
   - name
   - source page or frame
   - entry path or navigation relationship
   - core visible elements
   - mandatory changes such as hide, move, relabel, or link insertion
   - inclusion status
4. Record global directives that apply across screens
5. Record exclusions separately, with reasons
6. If scope is ambiguous, ask exactly one clarifying question
7. Save the result to `docs/visual-analysis/visual-source-analysis.md`
8. Hand off to `author-product-requirements`

## Hard Stop

Stop and ask one concise question if:

- It is unclear whether all visible screens are in scope
- A screen appears in the source but its product role is ambiguous
- A navigation path is implied visually but not clear enough to encode safely
- The artifact mixes optional ideas with mandatory UI in a way that cannot be inferred safely

## Auto Go

Continue without a question only when:

- Visible screens can be inventoried confidently
- Exclusions are explicit
- The analysis is strong enough to write requirements without silently shrinking the scope

## Strong Rules

- Count visible screens before writing requirements
- Do not silently drop a visible screen
- Do not treat "not implemented yet" as equivalent to "out of scope"
- If you exclude a screen, record the reason
- This skill writes analysis, not product requirements, plans, or code
- Every screen row must have a unique `V-NN` ID — this ID is the handoff contract to `generate-step-docs` and `verify-current-step`

## Output

- `docs/visual-analysis/visual-source-analysis.md`
- A handoff to `author-product-requirements` or one unresolved clarifying question

## Parallel Analysis (Optional)

When the visual source has many screens, screen-block analysis may fan out per `docs/parallelism-contract.md`:

- Each parallel analyzer reads its own screen block read-only
- Writing the merged `visual-source-analysis.md` is done by a single writer after fan-in
- Record `parallel-start` and `parallel-join` trace entries around the fan-out

## Success Condition

The harness has a structured visual analysis document that names the visible screens, mandatory directives, exclusions, and ambiguities well enough to write requirements without silently reducing the requested UI.
