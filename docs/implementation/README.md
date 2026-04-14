# Implementation Directory

This directory stores live execution state.

## Main File

- `implementation-state.md`

## Purpose

This is the current-position document for execution.

It should answer:

- which step is active
- what status the step is in
- what blockers exist
- what the next allowed action is

## Rules

- exactly one active step at a time
- implementation should follow step scope
- verifier, not executor, closes completion with evidence
