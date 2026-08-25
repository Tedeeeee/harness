---
name: personal-orchestration
description: Use when a user starts feature development, a feature fix, a bug recovery, or another behavior-changing task from a Claude or Codex session.
---

# Personal Orchestration

This is an optional personal overlay. It does not replace the repository's `AGENTS.md`, `CLAUDE.md`, or project Skills.

## Activation

Use this overlay only when `%APPDATA%/personal-harness/config.json` or `PERSONAL_HARNESS_ROOT` points to an active external installation with `mode: external-global` and `activation.enabled: true`. If it is missing or disabled, follow the repository's normal instructions and do not create a personal Worktree.

## Behavior-changing requests

On the first behavior-changing request in an unbound session—feature, bug fix, recovery, or any request that may change code, tests, schema, configuration, permissions, contracts, or runtime behavior:

1. Read the repository entry instructions and the `feature-orchestration` Skill.
2. Invoke the installed `scripts/start-feature-run.ps1` with the current project path and the user's original request. Use live mode; `-Preview` is only for an explicitly requested dry run or Harness tests.
3. Let Bootstrap create one feature Worktree and one Coordinator. Do not ask the user to run Bootstrap or choose a model, branch, Worktree, or phase.
4. The Coordinator stays in one conversation and handles requirements, design, implementation, verification, and integration. It explains each phase and asks only material decisions.

The current checked-out branch is the base snapshot. A dirty base Worktree is forked from the base branch HEAD; leave its uncommitted changes untouched and keep them outside the child Worktree. Never stash, reset, copy, or overwrite them.

Do not create child agents, specialist terminals, phase Tasks, or Dispatches for ordinary sequential work. Do not use a global prompt hook, session-state file, or automatic retry to control the flow. A Bootstrap failure is reported to the user; it is not hidden by a retry or a second Worktree.

## Read-only requests

Explanation, investigation, review, and Harness-design discussion do not create a Feature Worktree unless the user explicitly asks to implement a change.

## Project rules and model choice

The repository's rules and domain Skills always remain authoritative. The Coordinator selects the required Skills for the current phase. Claude Opus 5 is the default route, with the configured Codex fallback used only for an actual provider or quota failure. Fast mode is opt-in only when the original request contains the standalone marker `fast`.
