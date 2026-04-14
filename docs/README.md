# Docs Guide

This directory is the state layer for `self-harness`.

The harness should use these documents to recover current status instead of relying on session memory.

## Document Roles

- `requirements/`: human-authored product input
- `interview/`: confirmed planning decisions
- `plans/`: master plan and step docs
- `implementation/`: active execution state
- `verification/`: evidence-based completion records
- `state-model.md`: summary of the document system
- `document-lifecycle.md`: when each document is created and updated

## Core Rule

These docs are not just notes.

They are operational state.

If a later skill cannot tell what to do next, the first thing to inspect is whether the correct document exists and is up to date.
