---
name: architecture-design
description: Use when a confirmed change affects system boundaries, ownership, contracts, data flow, permissions, runtime behavior, or other structural decisions.
---

# Architecture Design

Turn the confirmed problem into a design the user can understand and approve. Protect ownership and dependency boundaries before implementation.

## Required analysis

- identify runtime, module, data, and rule owners;
- trace relevant request, state, data, and failure flows;
- distinguish existing contracts from proposed contracts;
- inspect at least one viable alternative for a material decision;
- describe compatibility, migration, security, operational, and rollback consequences.

## Design handoff

Return the recommended design, alternatives and trade-offs, components and dependency direction, contracts and state transitions, failure behavior, verification strategy, and explicit non-goals. Mark evidence, inference, and unresolved choices separately.

## Gate

Pause for explicit user approval when the design changes a boundary, data model, permission, authentication behavior, external contract, shared abstraction, migration, or irreversible operation. Do not send implementation work before the approved design and non-goals are clear.
