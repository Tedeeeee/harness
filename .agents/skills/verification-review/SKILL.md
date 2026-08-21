---
name: verification-review
description: Use when an implementation or proposed change must be checked against its request, design, project rules, tests, evidence, and remaining operational risk.
---

# Verification and Review

## Purpose

Determine whether the feature is supported by evidence, not whether the output sounds complete. Review independently from the implementation work.

## Review dimensions

- requested behavior and explicit non-goals;
- approved design, decisions, and changed boundaries;
- diff scope, public contracts, data and permission effects;
- project rules and applicable skill requirements;
- deterministic tests, static checks, builds, and relevant runtime checks;
- error paths, observability, rollback, and unverified assumptions.

## Required report

Return:

1. Passed conditions with concrete evidence.
2. Failed or missing conditions.
3. Risks, regressions, and unverified areas.
4. The smallest required next action: complete, revise, return to design, or stop for user decision.

Treat a test that was not run as unverified. Treat a failing check as a blocker unless the user explicitly accepts the risk. Do not repair implementation problems silently while acting as the reviewer; send them back with evidence.

## Gate

The feature orchestrator may issue a completion receipt only when the required checks pass, the approved scope is satisfied, and remaining risks are disclosed. If implementation differs from the approved design, return to the appropriate user gate before declaring success.

