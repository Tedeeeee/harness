# Interaction Gates

User interaction is intentionally broad in the first version. The orchestrator should ask for the user's view at phase boundaries and reduce questions only after repeated safe use demonstrates that a gate is unnecessary.

| Gate | Action |
| --- | --- |
| Inform | Explain the finding and continue when the work follows an established safe pattern. |
| Confirm | Ask one focused question when the request, scope, or impact is ambiguous. |
| Approve | Stop until the user explicitly accepts a meaningful design, risk, or scope decision. |
| Stop | Halt on conflicting evidence, failed verification, unsafe scope expansion, or missing authority. |

Always ask before finalizing new architecture boundaries, data models, permissions, authentication, security behavior, external contracts, irreversible operations, or changes that materially alter runtime behavior.

Do not ask the user to choose a model for every task. Model selection is an internal routing concern unless the choice changes cost, risk, capability, or user-visible behavior enough to require a decision.

