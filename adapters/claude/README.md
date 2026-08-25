# Claude Adapter

Claude reads the native skill mirror from .claude/skills/.

The external-global installer also registers the personal entry hook in the user's `~/.claude/settings.json`. `UserPromptSubmit` invokes live Harness Bootstrap for a behavior-changing request, and `PreToolUse` denies an unbound base-session tool call until a Feature Run and child Worktree are verified. The hook is machine-local; it is never copied into a project. A Claude session must be restarted after the global hook is installed or changed.

An ordinary Claude session is an entry session until a Feature Task and derived Feature Worktree are verified. On the first behavior-changing request, it invokes the live Harness Bootstrap automatically from the current checked-out branch; the user is not asked to run a separate command. It must not inspect or modify product files before the child Worktree is verified.

The adapter is responsible for Claude-specific invocation details only. Shared workflow rules, phase contracts, user gates, routing policy, and completion criteria remain in rules, core, and skills-src.

Claude Opus 5 is the default Feature Agent for every sequential phase: requirements, design, implementation, verification, and branch integration.

The exact High or Max variant is a provider configuration decision. The adapter must report the actual model that ran and must not silently replace it.

When a route advertises `fastCommand`, the same Feature Run opt-in may send `/fast` to the Claude Feature Agent. The default is off; the adapter must not enable Fast because a task appears simple or urgent. A real Claude quota or provider-availability failure may trigger the configured Codex fallback without changing the Run or Worktree.
