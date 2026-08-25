# Cognitive Debt Principles

Cognitive debt is created when automation produces changes that the responsible human cannot explain, operate, review, or safely change later.

The orchestrator protects understanding during the run by explaining current behavior, impact, alternatives, risks, and the next decision. This context lives in the active conversation and Orca runtime; the harness does not create a permanent transcript or phase-history directory.

When a feature changes, the target project must contain one current-state feature document. It describes how the feature works now, including flow, rules, contracts, affected areas, and verification. It is not an implementation diary.

Code, tests, operational evidence, and the current feature document are the durable evidence. Git preserves historical versions when historical comparison is needed.

The invariant is: do not advance past a meaningful decision while the user lacks enough information to understand and approve it, and do not complete a behavior change while the project document is stale.
