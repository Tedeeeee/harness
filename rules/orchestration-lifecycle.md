# Orchestration Lifecycle

One user-requested feature creates one Feature Run and one Orca child worktree. The run is temporary execution state; it is not a permanent history folder in the target project.

## User intent and intake

The user normally provides an intent, problem, or desired behavior only. The user does not need to provide a phase plan, model choice, specialist name, worktree name, test command, or stopping point.

Harness Bootstrap is the single entrypoint. It is invoked automatically by the first Claude or Codex session that receives a behavior-changing request. It derives the feature identity from the user's intent, uses the current checked-out branch as the base, creates one derived branch and Worktree, creates an Orca Run and Feature Task, and starts one configured Feature Agent. The user must not be asked to invoke the script manually.

An entry session may read only Harness instructions and safe Git preflight before Bootstrap succeeds. A dirty base Worktree stops intake. A session with an existing verified Run/Task/Feature Worktree resumes that Run and never creates a nested Worktree.

The Feature Agent performs an ephemeral intake before product work:

1. classify the request as behavior-changing work, explanation/investigation, review-only work, or a mechanical change;
2. select the smallest safe workflow, using Feature Run by default when code, tests, schema, configuration, permissions, external contracts, or runtime behavior may change;
3. choose the applicable project skills and risk level;
4. confirm the base branch, clean worktree, scope, and non-goals;
5. select the current phase Skills without asking the user to restate the process.

User-proposed solutions are evidence or hypotheses until requirements and design confirm them. A request such as "investigate and fix it" does not itself approve a data model, migration, permission, external-contract, or other material design decision.

Fast mode is disabled by default. Only a standalone `fast` marker in the original intent opts that Feature Run into Fast mode; otherwise the configured model and effort remain unchanged. Routes without a declared fast capability must be reported as a routing exception rather than silently substituted.

## External Harness mode

The personal Harness may be installed globally instead of copied into the target project. In external mode, the coordinator reads the installed Core and rules from the configured Harness location, while the target project keeps only its own code, rules, skills, and current feature documents. A project-local `.harness` directory is optional and must not be created solely to make orchestration possible.

## Phases

1. Requirements analysis: understand the request, current behavior, boundaries, risks, and unknowns.
2. Architecture design: propose a focused design, alternatives, contracts, and consequences.
3. Implementation: work only inside the approved scope and keep the project's current feature document accurate.
4. Verification and review: compare the request, rules, diff, tests, feature document, and remaining risk.
5. Branch integration: preview the current base branch, resolve conflicts with user-visible decisions, verify, and request merge approval.

Each phase returns a concise routing receipt and updates the current feature document when implementation has begun. Sequential phases remain in the same Feature Agent session; they do not require runtime handoffs.

## Automatic progression and gates

The coordinator advances between phases automatically. It asks focused questions only when the user must clarify scope or make a meaningful decision. Requirements confirmation, material design approval, verification failure, scope drift, merge approval, and push/PR approval are explicit gates; ordinary mechanical steps do not require a new prompt.

`Confirm` produces `user-confirmed` and can open architecture analysis. `Approve` produces `user-approved` only for the design, scope, risks, and non-goals shown at the architecture gate. Generic continuation such as "continue" or "proceed" is not approval and cannot enter implementation. The coordinator validates these transitions with `scripts/validate-feature-transition.ps1`.

## Runtime boundary

Orca owns Run, Task, Dispatch, worker terminals, ask/reply, gates, and worker completion. Harness Core owns phase order, model routing, user gates, project-documentation requirements, and integration rules.

The Feature Agent is the only user-facing agent. Skills return structured findings inside the same session instead of creating competing conversations. A user gate is an ordinary assistant response from that Feature Agent followed by a wait for the user's reply in the same session. `orca orchestration ask`, `reply`, and `send` are internal coordination only; they must not carry a user gate. Orca gate state records the decision but never replaces the visible chat question. Heartbeats and Run inbox messages are runtime-only. One Feature Run uses one derived Worktree and branch; child Tasks are disabled by default.

The Feature Agent does not start product work without a bound Orca Run and Feature Task. It reports the current phase, Run ID, Task ID, Worktree, routing receipt, and mutation permission; it reports phase changes, gate waiting, escalation, and blockers, with a heartbeat at least every 60 seconds while long work is active. Requirements and architecture phases are read-only against product files.
