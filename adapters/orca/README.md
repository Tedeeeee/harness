# Orca Adapter

This adapter maps Harness Core phases to Orca's versioned orchestration runtime.

## Runtime contract

Before using Orca commands:

1. resolve the executable according to the local Orca environment;
2. run Orca's version-matched orchestration skill command;
3. read that returned guide completely;
4. check runtime availability with the JSON status command;
5. start Orca only when the requested workflow requires live coordination.

Do not infer flags from this document. The Orca binary is the source of truth for command names and arguments.

## Feature Run mapping

- one Harness Feature Run maps to one Orca Run;
- one derived Worktree and branch are used for the whole Feature Run;
- one Feature Task owns the user conversation and the whole feature lifecycle;
- each Core phase changes Skill context inside the same Feature Agent session;
- the feature agent uses the route returned by scripts/route-agent.ps1;
- child Tasks and Dispatches are disabled for ordinary sequential phases;
- user confirmations and approvals are ordinary assistant responses in the Feature Agent chat, followed by the user's reply in that same session;
- Orca gate state records the decision after the visible question; `orca orchestration ask`, `reply`, and `send` are internal coordination only and must not carry a user gate;
- the Feature Agent advances after its own phase result or escalation;
- settled workers are released according to the live Orca guide.

## Bootstrap entrypoint

The supported entrypoint accepts the user's intent from any supported host. A plain Claude or Codex session invokes it automatically when the first behavior-changing request arrives; the user does not run a second command. It derives a feature title and ID, uses the current checked-out branch HEAD as the base snapshot, creates the derived branch/child Worktree, creates the Orca Run, creates one Feature Task, and starts one Feature Agent with the configured `coordinator` route. A dirty base is allowed; its uncommitted changes remain in the base and are excluded from the child. The user does not select the model or start specialist workers directly.

Before the live Bootstrap succeeds, the entry session may perform only Harness and safe Git preflight. It must not inspect product files, run project commands, access a database, install dependencies, or edit product files. A session already bound to the Feature Worktree resumes it instead of creating a nested Worktree. No global personal prompt hook is required.

The Feature Agent is the only user-facing agent. It performs requirements, design, implementation, verification, and integration in the same derived Worktree by routing Skills. A direct Codex or Claude terminal without a bound Feature Task is not an active Feature Run.

The Coordinator must present requirements findings, impact, recommended direction, non-goals, uncertainty, and the next decision directly in its own chat before waiting. It does not delegate ordinary phases to a parent coordinator or child worker.

Fast is not enabled by the adapter by default. The Bootstrap recognizes only a standalone `fast` marker in the original intent and freezes that preference on the Feature Run. The Coordinator may send the configured `/fast` service-tier toggle only to routes that declare `fastCommand`; reasoning effort remains unchanged. Unsupported routes are reported and require a decision rather than an automatic fallback.

## Mandatory runtime gates

- Create and bind the Orca Run and Feature Task before starting the Feature Agent. No Run or Task ID means no Feature Run.
- Before implementation, the Coordinator must have explained the design and received explicit approval. A generic "continue" or "proceed" reply must not be treated as design approval.
- Requirements analysis and architecture design workers are read-only against product files. An unexpected product diff before implementation is a gate violation: stop, preserve the diff, and report it.

The Coordinator reports progress through the Worktree, current phase, whether product files may change, gate waiting, and failures. Keep the progress report in the normal conversation; no heartbeat or routing receipt is required.

## State boundary

Run, Task, Dispatch, worker, and gate state stays in Orca. The adapter does not write .harness/runs or phase-history files into the target project.

## Worktree boundary

The project preflight identifies the user's base branch. Orca creates or attaches the one derived orchestration worktree for the Feature Run. Every phase reuses that worktree.

## Failure handling

Runtime unavailable, worker escalation, missing route capability, and task failure are reported to the user. The adapter does not silently substitute another provider or skip a gate.

## Supervised command sequence

Use the installed binary's exact command spelling and JSON output:

    orca orchestration run-create --objective <feature> --json
    orca orchestration task-create --spec <feature> --json
    orca orchestration worker-start --task <task-id> --worktree <selector> --agent <agent> --model <model> --json

Create only the Feature Task before starting the Feature Agent. Use worker-start once for the Feature Run. Verify provenance with task-list and dispatch-show. Do not create a phase worker for requirements, design, implementation, or verification.

When Claude reports an actual quota or provider-availability failure, resume the same Feature Task in the same exact Worktree with the configured Codex fallback. Do not create a second Run or Worktree. Do not switch provider merely because a phase is slow or simple.
