# self-harness

Canonical docs-first harness scaffold for a skill-driven workflow system.

This harness starts from the smallest stable structure:

- human-authored requirements
- interview decisions
- master plan
- step docs
- implementation state
- verification docs

The purpose of this directory is to hold the single canonical harness rather than multiple versioned experiments.

## Current Focus

This directory defines the docs-first state model plus the minimal skill set needed to run the harness end-to-end.

Planner entry points:

1. `assess-product-requirements`
2. `conduct-development-interview`
3. `generate-master-plan`
4. `generate-step-docs`

## Minimal Skill Set

### Planner

- `assess-product-requirements`
- `conduct-development-interview`
- `generate-master-plan`
- `generate-step-docs`

### Execution

- `implementation-start`
- `implement-current-step`
- `verify-current-step`
- `implementation-blocker`

### Routing

- `route-self-harness`

## Layout

- `START.md`: top-level operating contract for the harness
- `docs/requirements/`: human-authored product requirements
- `docs/interview/`: confirmed development decisions
- `docs/plans/`: master plan and step docs
- `docs/implementation/`: active step execution state
- `docs/verification/`: step verification evidence
- `examples/`: sample inputs kept separate from live operational state
- `templates/`: minimal reusable document shapes
- `skills/`: repo-local skills used by router, planner, executor, verifier, and blocker handling
