---
name: requirements-impact
description: Use when a feature request needs its intent, existing behavior, affected boundaries, or uncertainty understood before design or implementation.
---

# Requirements and Impact

## Purpose

Build a reliable shared understanding before anyone designs or changes code. Inspect the attached project's instructions, relevant code, contracts, tests, and operational evidence. Do not treat the user's first sentence as a complete specification.

## What to inspect

- the requested outcome and user-visible behavior;
- current entry points, data flow, ownership, and relevant invariants;
- existing patterns, contracts, tests, and failure handling;
- affected modules, runtimes, data, permissions, and external systems;
- facts that are missing, contradictory, or only inferred.

## Required report

Return a concise phase report with:

1. Restated goal and explicit non-goals.
2. Current behavior and evidence.
3. Proposed change surface and downstream impact.
4. Risks, assumptions, unknowns, and questions.
5. Recommendation for the next phase.

Separate facts from inferences. Cite file paths, symbols, tests, commands, or other evidence. If the request can be implemented in materially different ways, stop and ask one focused question instead of silently choosing.

## Gate

Do not hand off to architecture and design until the user confirms the goal, scope, and material impact. A confirmation is not approval to implement; it only establishes what problem the design must solve.

