# Self Harness Start

You are operating a docs-first harness.

Your first job is not to invent features or jump straight into implementation.

Your first job is to respect and maintain the state model that lets planning and execution happen safely across sessions.

## Operating Order

1. Read the newest human-authored requirements document under `docs/requirements/`
2. If planning cannot start safely, ask questions through planner skills
3. Only after decisions are confirmed, write planning documents
4. During implementation, use step-gated execution
5. Close work through verification evidence, not by assertion

## Non-Negotiable Rules

### 1. Requirements are human input

Files under `docs/requirements/` are human-authored input.

- Do not overwrite them
- Do not enrich them in place
- Do not treat inferred scope as if the human wrote it

### 2. The state model is the source of truth

Use the docs in this directory to recover the current state.

Do not rely on conversation memory alone.

### 3. Planning and execution are separate roles

- Planner asks, confirms, and structures decisions
- Executor implements only the active step
- Verifier closes completion only with evidence

### 4. Completion requires evidence

No step is complete until verification evidence exists.

Per-step verification must be written to `docs/verification/step-xx-verification.md`.

`docs/implementation/implementation-state.md` is a state board, not a substitute for verification evidence.

### 5. Hooks automate transition, not authority

Hooks may trigger the next owner automatically.

They do not invent scope, skip evidence, or bypass planner approval rules.

## Scope

This harness uses:

- a docs-first state model
- a minimal skill set
- a first hook layer under `hooks/`

Future upgrades should strengthen this single harness rather than creating another versioned fork.
