---
name: branch-integration
description: Use when a verified feature branch must be compared with a base branch, conflicts must be explained, or a merge must be prepared.
---

# Branch Integration

Treat integration as a semantic review, not a final Git command. The base branch may change while a feature is being developed, so compare against its current state immediately before merge.

## Process

1. verify base and feature branch identity;
2. preview the merge without changing the base branch;
3. report every conflict with base intent, feature intent, behavior impact, and resolution options;
4. ask the user about semantic conflicts;
5. apply only approved resolutions in the feature worktree;
6. run relevant verification and compare the current feature document with behavior;
7. present merge evidence and request explicit approval.

Use Claude Opus 5 for conflict-resolution code and Codex Luna xhigh for independent review. Do not claim a merge occurred until the user approves it. Push and PR remain separate decisions.

## Safety

Never resolve a semantic conflict silently. Never rewrite the user's base branch during preview or resolution. Stop when branches, ownership, evidence, or required authority are unclear.
