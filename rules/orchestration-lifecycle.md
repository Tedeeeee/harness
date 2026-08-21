# Orchestration Lifecycle

One user-requested feature creates one feature-orchestration run. The run owns the current understanding, decisions, delegated work, evidence, and next gate. It is a runtime instance of a reusable workflow, not a new permanent codebase for every feature.

## Phases

1. Requirements and impact: understand the request, existing behavior, boundaries, risks, and unknowns.
2. Architecture and design: propose a focused design, alternatives, contracts, and consequences.
3. Implementation: work only inside the approved scope and report material deviations.
4. Verification and review: compare the request, rules, diff, tests, and remaining risk.

Every phase produces a concise handoff containing:

- scope and current understanding;
- evidence inspected;
- decisions and alternatives;
- unresolved questions and risks;
- recommendation for the next gate.

The feature orchestrator is the only user-facing coordinator. Specialist skills return structured findings to it instead of independently creating competing user conversations.

