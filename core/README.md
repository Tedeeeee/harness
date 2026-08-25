# Harness Core

Harness Core is the provider-neutral contract layer for the personal orchestration harness.

It defines:

- the Feature Run and integration phase order;
- the single Bootstrap entrypoint, feature identity, derived Worktree, and Feature Agent boundary;
- single-session phase Skill routing and routing receipts;
- user gates and phase routing receipts;
- role-to-model routing;
- explicit per-Feature-Run Fast opt-in policy;
- branch and worktree expectations;
- the current-state feature document requirement.
- hard phase-transition gates, supervised Orca Run/Task requirements, and progress-reporting expectations.

The Core supports two deployment modes. In external-global mode, `scripts/sync-global-harness.ps1` installs Core, rules, templates, adapters, scripts, and the optional personal Skills into the user's global locations; the target project does not need a `.harness` directory. The personal overlay is active only when the global `personal-harness/config.json` is readable and explicitly enabled. Without that activation config, agents follow the target project's own instructions and Skills.

In project-overlay mode, generic Feature Skills and Core are copied into the target project for an explicitly shared deployment. The overlay does not copy `personal-orchestration`, modify `AGENTS.md` or `CLAUDE.md`, or impose one developer's personal entrypoint on other contributors.

Orca remains the runtime authority for Run, Task, Dispatch, worker terminals, internal ask/reply, gates, and worker completion. User gates are delivered in the Feature Agent chat; Core does not copy Orca runtime state into the target project.

The Bootstrap is invoked automatically by the first Claude or Codex session that receives a behavior-changing request. It creates one Orca Run, one derived child Worktree from the current branch, one Feature Task, and one Feature Agent. The Feature Agent owns the user conversation and changes phase by reading the required Skill; ordinary sequential phases do not create child Tasks or Dispatches. A dirty base Worktree or an unverified binding stops intake. The Feature Run cannot enter implementation until the architecture gate has produced `user-approved` for the shown design. Generic continuation is not approval. `scripts/validate-feature-transition.ps1` is the machine-checkable phase boundary.

The files in this directory are intentionally small and machine-readable. Provider-specific command details belong under adapters.
