---
name: verification-and-review
description: Use when an implementation or branch integration must be checked against its request, design, project rules, tests, current feature documentation, and remaining risk.
---

# Verification and Review

Review independently from implementation. Determine whether the result is supported by evidence, not whether it sounds complete.

## Review

- requested behavior and explicit non-goals;
- approved design and changed boundaries;
- diff scope, public contracts, data, permissions, and migrations;
- project rules and applicable skills;
- deterministic tests, static checks, builds, and relevant runtime checks;
- error paths, rollback, observability, and unverified assumptions;
- current feature document versus actual code behavior.

## Report

Return passed conditions with evidence, failed or missing conditions, risks and regressions, unverified areas, and the smallest next action: complete, revise, return to design, or stop for user decision.

Treat a test not run as unverified. Treat a failing check as a blocker unless the user explicitly accepts the risk. Do not silently repair implementation problems while acting as reviewer.

## Gate

Completion requires required checks to pass, approved scope to be satisfied, and the current project feature document to match the implementation. Return to the responsible phase when any condition fails.
