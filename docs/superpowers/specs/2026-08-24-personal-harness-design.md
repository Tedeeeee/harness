# Personal Orchestration Harness Design

## Goal

Provide one provider-neutral workflow that lets Orca execute feature work while Harness Core controls user gates, role-specific model routing, project documentation, and branch integration.

## Design

Orca owns runtime state: Run, Task, Dispatch, worker terminals, internal ask/reply, gates, and worker completion. Harness Core owns the rules that Orca executes: phase order, approval boundaries, handoff contracts, model routing, worktree policy, merge conflict handling, and completion checks. User gates are ordinary responses in the single Feature Agent chat; Orca ask/reply and Run inbox messages are never the user conversation.

One feature uses one Orca Run and one child worktree. The phases are sequential:

1. requirements-analysis
2. architecture-design
3. implementation
4. verification-and-review
5. branch-integration

The first two phases use Codex Sol with high reasoning effort. Implementation uses Claude Opus 5. Verification uses Codex Luna with xhigh reasoning effort. A merge conflict is resolved by the implementation model and independently checked by the verification model.

## Project documentation

The harness does not persist run history, phase reports, model transcripts, or cognitive-debt logs in the target repository. A completed feature updates one project-owned current-state document under docs/features/<feature-id>.md. The document describes present behavior, rules, flow, contracts, affected areas, and verification. Git provides historical versions.

The harness supplies the template and requires the document to be updated when feature behavior changes. Verification checks that the document is present and consistent with the implementation.

## User gates

The Feature Agent presents the findings and recommended direction in its own chat, then asks for confirmation after requirements and impact analysis, approval after architecture and design, and approval before merge. Push and PR are separate decisions. It stops on contradictory evidence, failed verification, unsafe scope expansion, or a decision that requires user authority. The Orca gate records the answer after the visible chat exchange; it does not replace it.

## Branch integration

The user supplies a base working branch. Orca creates a derived orchestration worktree. The base branch is not edited during the run. Before merge, the harness previews the current base, reports conflicts by file and intent, waits for user decisions on semantic conflicts, runs verification, and only then allows merge.

## Routing evidence

Arena Agent leaderboard data is an input to routing, not an automatic runtime decision. A feature run freezes a routing snapshot at start. The snapshot records the source URL, capture time, category, model evidence, and the local effort policy. If a model or effort is unavailable, the orchestrator reports the fallback and asks for approval when capability or cost changes materially.

## Acceptance criteria

- Codex and Claude receive identical source skills.
- The six task-oriented skills are discoverable by their activity names.
- Core workflows and contracts are machine-readable.
- A route command returns the configured provider, model, effort, and evidence for each phase.
- A project feature document is the only durable feature artifact created by the harness.
- Contract tests detect missing mirrors, stale skill names, invalid JSON, and invalid routes.
