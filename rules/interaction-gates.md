# Interaction Gates

The Feature Agent keeps the user interaction small, but a gate is a state transition, not conversational politeness. A delegated worker cannot create or infer a user gate.

| Gate | Meaning | Permits | Does not permit |
| --- | --- | --- | --- |
| Inform | Report a safe, non-decisional result. | Continue the already-authorized phase. | Crossing a material design or scope decision. |
| Confirm | Confirm the current understanding, scope, or impact. | Move from requirements analysis to architecture design. | Implementation, migration, permission, or merge approval. |
| Approve | Explicitly accept the shown design, scope, risks, and non-goals. | Enter implementation for that approved design. | Work outside the approved scope or merge/push. |
| Stop | Halt on conflict, failed verification, unsafe expansion, missing authority, or unverified runtime state. | Nothing until the blocker is resolved. | Silent recovery or a guessed substitute. |

The exact decision must be recorded in the Orca gate state by the Feature Agent and validated by `scripts/validate-feature-transition.ps1`.

## User-facing gate transport

The Feature Agent is launched as an Orca worker, but it is the direct conversational owner. A user gate must be presented as an ordinary assistant response in the Feature Agent's own chat:

1. explain the findings, impact, proposed direction, non-goals, and uncertainty;
2. ask one focused question or explicit approval request;
3. stop and wait for the user's reply in the same session.

`orca orchestration ask`, `reply`, and `send` are internal coordination commands. They must not be used to deliver a user gate, and a pending Orca Run message or gate payload must not be the only user-visible question. `gate-create` records runtime state but does not replace the direct chat response. Heartbeats and `check --run` output are runtime-only and must be filtered from the user conversation.

If the Feature Agent cannot put the findings and question into its own chat, it must report an adapter routing failure and stop rather than waiting on an internal coordinator.

"Continue", "proceed", "go on", and equivalent generic continuation are not approval. They may acknowledge a requirements result when no material ambiguity remains, but continue is not design approval and cannot enter implementation. The Feature Agent must ask for an explicit approval after presenting the design when the workflow requires it.

Always ask before finalizing new architecture boundaries, data models, permissions, authentication, security behavior, external contracts, irreversible operations, or changes that materially alter runtime behavior.

Do not ask the user to choose a model for every task. Model selection is an internal routing concern unless the choice changes cost, risk, capability, or user-visible behavior enough to require a decision.
