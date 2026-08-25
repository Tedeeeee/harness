---
name: implementation
description: Use when approved requirements and design must become focused code, tests, migrations, configuration, and the project's current feature document.
---

# Implementation

Produce the smallest reliable change inside the approved scope. The attached project's rules, architecture, tests, and current feature documentation are authoritative.

## Before editing

- read the approved understanding and design;
- inspect exact files, contracts, tests, and existing patterns;
- state the intended file set and verification commands;
- identify mismatches between the approved design and current code.

## While editing

- preserve ownership and dependency direction;
- follow project language, framework, database, and testing rules;
- add or update tests for changed behavior;
- update docs/features/<feature-id>.md so it describes the behavior after this change;
- report a material scope or design deviation before implementing it.

Do not choose a new architecture during implementation. Do not silently expand scope. Do not claim a test passed unless it was run and evidence is available.

## Handoff

Return changed files, current behavior, intentionally unchanged behavior, the project feature document path, tests run, failures or skipped checks, and remaining decisions. Hand off only when the approved implementation is ready for independent review.
