---
name: architecture-design
description: Use when a requested change affects system boundaries, ownership, contracts, data flow, permissions, runtime behavior, or other structural decisions.
---

# Architecture and Design

## Purpose

Turn an approved problem definition into a design the user can understand and decide on. Protect ownership and dependency boundaries before implementation begins.

## Required analysis

- identify the runtime, module, data, and rule owners;
- trace the relevant request, state, data, and failure flows;
- distinguish existing contracts from proposed contracts;
- inspect at least one viable alternative when the decision is material;
- describe compatibility, migration, security, operational, and rollback consequences.

## Design report

Present:

1. Recommended design and why it fits the confirmed goal.
2. Alternatives considered and their trade-offs.
3. Components, responsibilities, and dependency direction.
4. Contracts, state transitions, data ownership, and failure behavior.
5. Verification strategy and explicit out-of-scope work.

Use evidence from the project. Mark inferences and unresolved choices. Do not convert a specialist preference into a user decision without explaining the consequence.

## Gate

Pause for explicit user approval when the design introduces or changes a boundary, data model, permission, authentication behavior, external contract, shared abstraction, migration, or irreversible operation. Do not send implementation work before the approved design and non-goals are recorded.

