---
name: analyze-visual-source
description: Use when the user provides a PDF, image set, wireframe, prototype, screenshot collection, prototype code bundle, or other source artifact that must be converted into a structured analysis before requirements authoring or planning.
---

# Analyze Visual Source

## Overview

This skill turns a visual or prototype source into a structured analysis document.

It exists to stop the harness from skipping directly from a PDF, mockup, or prototype code bundle to requirements while silently dropping screens, links, flows, or product intent.

## When to Use

- The main input is visual or prototype-driven rather than a full text requirements document
- The user wants the final UI to match a PDF, wireframe, screenshot set, prototype, or prototype code bundle
- The harness needs to know which screens, interactions, and data signals actually exist before writing requirements

Do not use this skill when a complete text requirements document is already the primary source of truth and the visual or prototype artifact is only loose inspiration.

## Read These First

- `CLAUDE.md`
- `templates/visual-source-analysis-template.md`
- Existing files in `docs/visual-analysis/`

## Core Rule

Never promote a source artifact directly into implementation scope.

First create a screen and behavior inventory, record exclusions, and surface ambiguity.

Prototype code is a `requirements draft input`, not a final implementation contract.

## Process

1. Read the source artifact itself
2. Classify the source type:
   - PDF / image / wireframe / screenshot set
   - interactive prototype
   - HTML / JSX / CSS prototype code bundle
3. Identify every distinct screen, view, or navigable state visible or encoded in the source
4. Record each screen with:
   - id (`V-NN`, unique, never reused)
   - name
   - source page or frame
   - entry path or navigation relationship
   - core visible elements
   - mandatory changes such as hide, move, relabel, or link insertion
   - inclusion status
   - confidence tag
   - source reference if available
5. If the source includes prototype code, also extract:
   - route or navigation signals
   - interaction inventory
   - data or entity signals
   - design token or theme signals
   - prototype-only implementation notes
6. Record global directives that apply across screens
7. Record exclusions separately, with reasons
8. If scope is ambiguous, ask exactly one clarifying question
9. Save the result to `docs/visual-analysis/visual-source-analysis.md`
10. Hand off to `author-product-requirements`

## Confidence Tags

Every extracted item should use one of these tags:

- `explicit`: directly stated in the source artifact
- `inferred`: strongly implied by the source artifact
- `demo-suspect`: likely demo convenience logic or temporary implementation
- `needs-confirm`: unclear whether it is part of the real product contract

Prefer attaching a source reference such as file path, component name, page number, or frame name whenever possible.

## Hard Stop

Stop and ask one concise question if:

- It is unclear whether all visible screens are in scope
- A screen appears in the source but its product role is ambiguous
- A navigation path is implied visually but not clear enough to encode safely
- The artifact mixes optional ideas with mandatory UI in a way that cannot be inferred safely
- A prototype-code artifact contains behavior that may be either product intent or demo-only scaffolding and the distinction materially affects requirements authoring

## Auto Go

Continue without a question only when:

- Visible screens can be inventoried confidently
- Exclusions are explicit
- The analysis is strong enough to write requirements without silently shrinking the scope
- Prototype-only behavior can be tagged safely instead of being mistaken for final product requirements

## Strong Rules

- Count visible screens before writing requirements
- Do not silently drop a visible screen
- Do not treat "not implemented yet" as equivalent to "out of scope"
- If you exclude a screen, record the reason
- This skill writes analysis, not product requirements, plans, or code
- Treat prototype code as a requirements-draft input, not a final implementation contract
- Separate product intent from demo implementation whenever possible
- Every screen row must have a unique `V-NN` ID — this ID is the handoff contract to `generate-step-docs` and `verify-current-step`

## Output

- `docs/visual-analysis/visual-source-analysis.md`
- A handoff to `author-product-requirements` or one unresolved clarifying question

## Parallel Analysis (Optional)

When the source artifact has many screens, screen-block analysis may fan out per `docs/parallelism-contract.md`:

- Each parallel analyzer reads its own screen block read-only
- Writing the merged `visual-source-analysis.md` is done by a single writer after fan-in
- Record `parallel-start` and `parallel-join` trace entries around the fan-out

## Success Condition

The harness has a structured analysis document that names the visible screens, behaviors, directives, exclusions, and ambiguities well enough to write requirements without silently reducing the requested UI or over-trusting demo implementation details.
