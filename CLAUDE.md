# Self Harness Start

You are operating a docs-first harness.

Your first job is not to implement immediately. Your first job is to recover state and decide the correct next owner.

## Operating Order

1. If the previous project is complete and the user is starting new work, use `project-transition`
2. Read the latest active input from `docs/requirements/`
3. If the main input is a PDF, image set, wireframe, screenshot collection, or prototype, create `docs/visual-analysis/visual-source-analysis.md` before requirements authoring
4. Confirm the technical approach before detailed planning starts
5. Ask through planner skills if planning cannot safely continue
6. Track planning progress with `docs/plans/planning-state.md`
7. Only write planning docs after decisions are confirmed
8. During implementation, use step-gated execution
9. Close completion with verification evidence, not claims

## Operating Rules

### 1. Requirements are human input

Files under `docs/requirements/` are human-authored input.

- Do not overwrite them
- Do not interpret them too aggressively
- Do not treat extracted scope as if it were confirmed by the user

### 2. Visual sources are analyzed before they become requirements

PDFs, wireframes, prototypes, screenshots, and similar visual sources are not promoted directly into requirements.

First convert them into `docs/visual-analysis/visual-source-analysis.md`.

That analysis must:

- inventory visible screens
- record mandatory hidden, moved, linked, or relabeled elements
- record explicit exclusions
- raise one concise question if visual scope is ambiguous

### 3. State documents are the source of truth

Recover current state from `docs/`, not from conversation memory alone.

### 4. Planning and execution are separate roles

- Planner asks, confirms, and structures decisions
- Executor only works on the current active step
- Verifier closes steps using evidence

### 5. Completion requires evidence

Every completed step needs a verification document under `docs/verification/step-xx-verification.md`.

`docs/implementation/implementation-state.md` is a state board, not a replacement for verification evidence.

### 6. Hooks may connect flow, but not bypass rules

Hooks may trigger the next owner automatically.

Hooks may not invent scope, skip evidence, or bypass planner confirmation rules.

## Scope

This harness currently includes:

- docs-first state model
- planning, execution, verification, and closure skills
- runtime hooks
- memory
- visual-source analysis before requirements promotion
