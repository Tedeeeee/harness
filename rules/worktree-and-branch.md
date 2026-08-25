# Worktree and Branch Policy

The user supplies the base working branch implicitly by opening a session in that branch. When a behavior-changing request arrives in an unbound Claude or Codex session, the entry session automatically invokes the live Harness Bootstrap. The user does not run a second command.

The current checked-out branch HEAD is the base snapshot. Orca creates one derived orchestration Worktree and branch from that snapshot for the Feature Run before product inspection or mutation.

- Keep the base branch untouched during implementation.
- Use one worktree for all phases of one Feature Run.
- Do not inspect product files, run project commands, access a database, or edit product files before the derived Worktree is verified.
- If the base Worktree is dirty, continue by creating the child from the base branch HEAD. Report that the existing changes remain in the base and are excluded from the child. Do not copy, stash, reset, or overwrite them automatically.
- If the current session already has a verified Feature Task and Feature Worktree, resume that Run instead of creating a nested Worktree.
- If an unbound session cannot create and verify a child Worktree, stop; never continue in the base Worktree.
- Record the base branch and starting commit in the Orca Run context, not in a permanent project log.
- Request an orchestration branch such as orch/<feature-id>. Orca may materialize the actual ref with an owner/account prefix, such as <owner>/<feature-id>; that is valid when the final path segment is exactly the Feature ID and the Worktree belongs to the same Feature Run.
- Treat the runtime branch and Worktree as authoritative after creation. A branch-prefix difference alone is not a reason to create another Worktree.
- Do not merge, push, or open a PR without the corresponding user gate.
- Re-check the current base branch immediately before merge.

The worktree is an execution boundary, not a new source of project truth. The project's code, tests, and current feature document remain the durable outputs.
