# Claude Entry Point

This repository is the personal orchestration harness. Before changing it, read README.md and the rules that apply to the requested change.

The harness is project-agnostic. Keep domain rules, code, tests, and current feature behavior documents in the attached project. Keep shared skills in skills-src, then mirror them into .agents/skills and .claude/skills with the repository scripts.

External-global is the default personal deployment mode. A target project does not need a `.harness` directory or copied generic skills; use the installed Harness Core and global native skill locations. Project-overlay mode is optional and must be treated as deployment infrastructure, not product behavior.

Harness Core owns the simple phase order, model route, user explanations, Worktree policy, integration rules, and completion checks. Orca owns the live runtime needed to create the one Worktree and one Coordinator.

Users normally provide intent only. The feature orchestrator classifies the request, selects the workflow and skills, and creates the required gates; do not require users to provide a phase plan or model choice in every prompt.

When a Claude or Codex session receives its first behavior-changing request, invoke the live Harness Bootstrap before product work. It creates one derived child Worktree and one Coordinator. Do not ask the user to choose the model, branch, Worktree, or phases. A dirty base Worktree is allowed: create the child from the current branch HEAD, preserve base changes, and exclude them from the child. Do not create child agents or phase workers.

Do not create a permanent orchestration-history directory in an attached project. A behavior change must update the project's current feature document, normally docs/features/<feature-id>.md.

Do not advance past a meaningful decision without explaining the understanding, impact, alternatives, uncertainty, and requested user decision. Do not claim completion without deterministic verification evidence.
