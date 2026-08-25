# Codex Adapter

Codex reads the native skill mirror from .agents/skills/.

The adapter is responsible for Codex-specific invocation details only. Shared workflow rules, phase contracts, user gates, routing policy, and completion criteria remain in rules, core, and skills-src.

Codex is the configured fallback Feature Agent when Claude reports an actual quota or provider-availability failure. It resumes the same Run, Feature Task, Worktree, branch, and current feature document with GPT-5.6 Sol high.

An ordinary Codex session is an entry session until a Feature Task and derived Feature Worktree are verified. On the first behavior-changing request, it invokes the live Harness Bootstrap automatically from the current checked-out branch; the user is not asked to run a separate command. It must not inspect or modify product files before the child Worktree is verified.

The route command reports logical model identifiers and Arena evidence. The adapter must verify that the local Codex runtime supports the selected model and effort before claiming that route was used.

Fast is a Codex service-tier toggle, not a reasoning effort. The default service tier is `default`; the Feature Agent sends `/fast` only when the original Feature Run intent contains the standalone `fast` marker. This keeps reasoning settings independent from speed and avoids silently increasing usage cost.
