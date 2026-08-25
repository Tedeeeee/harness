# Personal Orchestration Harness Implementation Plan

> For agentic workers: REQUIRED: Use superpowers:subagent-driven-development (if subagents are available) or superpowers:executing-plans to implement this plan. Steps use checkbox syntax for tracking.

Goal: Implement the approved provider-neutral Harness Core around Orca with current-state project feature documentation, role routing, mirrored skills, and branch integration contracts.

Architecture: Core JSON workflows and contracts describe the stable lifecycle. PowerShell scripts validate contracts, select the configured route, and synchronize skill mirrors. Orca adapter documentation describes the versioned runtime commands without duplicating Orca state in the repository.

Tech Stack: Markdown, JSON Schema-shaped contracts, PowerShell 7-compatible scripts, Pester-free PowerShell contract tests.

---

## Chunk 1: Core contracts and routing

Files:
- Create: core/README.md
- Create: core/agent-routing.json
- Create: core/workflows/feature-run.json
- Create: core/workflows/integration-run.json
- Create: core/contracts/handoff.schema.json
- Create: core/contracts/conflict-report.schema.json
- Create: core/contracts/merge-receipt.schema.json
- Create: scripts/route-agent.ps1
- Create: scripts/validate-json-contracts.ps1
- Test: tests/harness-contract.tests.ps1

- [ ] Add failing assertions for the required JSON files, phase order, route output, and project-documentation rule.
- [ ] Run the contract test and confirm it fails because the new contracts and route command do not exist.
- [ ] Add the minimal JSON workflows, contracts, and route command.
- [ ] Run the focused contract test and confirm it passes.

## Chunk 2: Rules and project feature document

Files:
- Modify: rules/orchestration-lifecycle.md
- Modify: rules/cognitive-debt.md
- Modify: rules/completion.md
- Create: rules/project-feature-documentation.md
- Create: rules/worktree-and-branch.md
- Create: rules/integration-and-conflict.md
- Create: templates/feature-document.md
- Create: templates/conflict-report.md
- Modify: templates/completion-receipt.md

- [ ] Add the current-state documentation rule and remove permanent run-history expectations.
- [ ] Add worktree and conflict rules that match the Core workflows.
- [ ] Add the project feature-document template.
- [ ] Run the contract test and documentation checks.

## Chunk 3: Task-oriented mirrored skills

Files:
- Delete: skills-src/feature-orchestrator/SKILL.md
- Delete: skills-src/requirements-impact/SKILL.md
- Delete: skills-src/verification-review/SKILL.md
- Create: skills-src/feature-orchestration/SKILL.md
- Create: skills-src/requirements-analysis/SKILL.md
- Create: skills-src/verification-and-review/SKILL.md
- Create: skills-src/branch-integration/SKILL.md
- Modify: skills-src/architecture-design/SKILL.md
- Modify: skills-src/implementation/SKILL.md
- Mirror: .agents/skills and .claude/skills
- Modify: scripts/sync-skills.ps1
- Modify: tests/harness-contract.tests.ps1

- [ ] Add failing assertions for the six activity-named skills and absence of stale names.
- [ ] Run the contract test and confirm it fails.
- [ ] Write concise source skills with only the task-specific instructions.
- [ ] Synchronize Codex and Claude mirrors.
- [ ] Run mirror and frontmatter checks.

## Chunk 4: Orca and provider adapters

Files:
- Create: adapters/orca/README.md
- Modify: adapters/codex/README.md
- Modify: adapters/claude/README.md
- Modify: AGENTS.md
- Modify: CLAUDE.md

- [ ] Document the version-matched Orca guide requirement and Run/Task/Worker lifecycle.
- [ ] Document provider-specific model mapping without pretending a model was invoked when unavailable.
- [ ] Make both entry points reference the same project-documentation and routing rules.

## Chunk 5: Repository guide and verification

Files:
- Modify: README.md
- Modify: tests/harness-contract.tests.ps1

- [ ] Update the tree, lifecycle, routing table, and current-state feature-document explanation.
- [ ] Run the JSON validator, route smoke tests, mirror checks, contract tests, and git diff checks.
- [ ] Inspect the final diff for stale run-history language and untracked required files.
