---
name: requirements-analysis
description: Use when a feature request needs current behavior, scope, affected boundaries, risks, and unknowns understood before design or implementation.
---

# Requirements Analysis

Build a shared understanding before design or code. Treat the user's request as an intent signal, not a complete specification.

## Inspect

- requested outcome and user-visible behavior;
- existing entry points, data flow, ownership, and invariants;
- relevant contracts, tests, failure handling, and operational behavior;
- affected modules, runtimes, data, permissions, and external systems;
- facts that are missing, contradictory, or inferred.

## Report

Return a concise handoff containing:

1. goal and explicit non-goals;
2. current behavior with file or command evidence;
3. proposed change surface and downstream impact;
4. risks, assumptions, unknowns, and focused questions;
5. recommendation for the next phase.

Separate facts from inferences. Do not design or implement. Do not make a material product decision for the user.

## Gate

Stop for user confirmation when scope, behavior, ownership, data, permissions, or external impact is materially ambiguous. Confirmation establishes the problem to design; it is not implementation approval.
