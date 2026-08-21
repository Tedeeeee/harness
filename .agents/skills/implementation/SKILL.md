---
name: implementation
description: Use when requirements and design have been confirmed and approved code changes, tests, migrations, or configuration must be produced.
---

# Implementation

## Purpose

Produce the smallest reliable change inside the approved scope. Treat the attached project's rules, existing architecture, and tests as authoritative.

## Before editing

- read the approved phase report, decision card, and implementation-start record;
- inspect the exact files, public contracts, tests, and patterns to change;
- state the intended file set and verification commands;
- identify any mismatch between the approved design and the existing code.

## While editing

- preserve ownership and dependency boundaries;
- follow the project's language, framework, testing, and safety rules;
- keep changes focused and avoid opportunistic refactors;
- add or update tests for changed behavior;
- report a material scope or design deviation before implementing it.

Do not choose a new architecture during implementation. Do not silently expand scope because a nearby cleanup looks attractive. Do not claim a test passed unless it was actually run and its result is available.

## Handoff

Return changed files, behavior changed, behavior intentionally unchanged, tests run, failures or skipped checks, and any remaining decision. Hand off to verification only when the approved implementation scope is complete enough to test.

