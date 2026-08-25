---
name: feature-orchestration
description: Use when a feature request needs coordinated requirements, design, implementation, verification, and branch integration across one worktree.
---

# Feature Orchestration

This Skill defines the simple Feature Run: one feature request, one Worktree, one Coordinator, and one user conversation. A phase changes the Coordinator's instructions and required Skills; it does not create another agent.

## When to use it

Use a Feature Run for a feature, bug fix, recovery, or any behavior-changing work. Stay read-only for questions, investigation, review, and Harness discussion unless the user explicitly asks for implementation.

The personal overlay is active only when the external global installation at `%APPDATA%/personal-harness/config.json` or `PERSONAL_HARNESS_ROOT` is enabled, or the project has an explicit `.harness/config.json`. Without activation, follow the repository's own instructions and do not create a personal Run or Worktree merely because this Skill is installed.

## Bootstrap

For an active behavior-changing request, run the installed `scripts/start-feature-run.ps1` in live mode. It derives the Feature ID and branch label from the request, creates one child Worktree from the current checked-out branch HEAD, creates the runtime identity, and starts one Coordinator.

`-Preview` is restricted to Harness tests or an explicitly requested dry run; it is not the normal feature workflow.

The user should only describe the problem or desired feature. The user does not need to name a branch, Worktree, model, phase, or specialist. A dirty base Worktree is allowed: fork the child from the base branch HEAD, preserve its uncommitted changes in the base, and exclude them from the child. Never stash, reset, copy, or overwrite base changes.

Do not create child agents, specialist terminals, phase Tasks, or Dispatches for ordinary sequential work. Do not install or depend on a global prompt hook, session-state file, or automatic retry. If Bootstrap fails, explain the failure and stop; do not silently work in the base or create a second Worktree.

## Coordinator conversation

The Coordinator owns the feature conversation and explains the current phase before doing work. User decisions are asked in the normal assistant response, not through an internal runtime inbox. Internal runtime messages, heartbeats, and status checks are never presented as the user's conversation.

At startup, state the feature title, derived branch, Worktree, current phase, and whether product files may change. Keep updates concise while working. Never leave the user guessing whether the agent is investigating, waiting for a decision, implementing, or verifying.

## Phase order

1. **Requirements analysis** — inspect the relevant current behavior, affected paths, impact, risks, and unknowns. Do not edit product files. Explain the findings and ask one focused requirements question when needed.
2. **Architecture and design** — select the smallest safe design, explain alternatives, data and contract effects, non-goals, and verification plan. Do not edit product files. Ask for explicit design approval before implementation.
3. **Implementation** — read the relevant implementation and project Skills, make the approved change in the Feature Worktree, and add or update focused tests.
4. **Verification and review** — run the relevant checks, inspect the diff, compare the result with the request and approved design, and report remaining risk.
5. **Branch integration** — compare the feature branch with its base, explain conflicts or integration effects, verify after any resolution, and ask separately before merge, push, or PR.

The initial request is an intent, not automatic approval of an unexamined design. “Continue” may move analysis to design, but it does not approve implementation. The Coordinator must not cross a material decision silently.

## Skill routing

Read only the Skills relevant to the current phase and affected project areas. Typical routing is:

- requirements: `requirements-analysis`, `architecture`, affected domain Skills, and `test`;
- design: `architecture-design`, `architecture`, affected domain Skills, and `test`;
- implementation: `implementation`, affected backend/frontend/crawler/database Skills, and `test`;
- verification: `verification-and-review` and `test`;
- integration: `branch-integration`, `verification-and-review`, and `test`.

The repository's `AGENTS.md` and native project Skills remain authoritative. This Skill only defines the single-Coordinator flow.

## Current implementation document

When the project uses a feature document, keep the latest implementation state there: behavior, important contracts, data flow, operational notes, and verification status. It is not a transcript or decision diary.

## Fast and provider fallback

The default route is Claude Opus 5. Use the configured Codex route only after a real provider or quota failure, preserving the same Worktree and conversation. Fast mode is disabled by default and applies only when the original request contains the standalone prompt marker `fast`; never infer it from a short or easy task.
