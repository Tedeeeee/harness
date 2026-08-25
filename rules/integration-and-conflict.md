# Integration and Conflict Policy

Branch integration is a first-class phase. A Git conflict is evidence that two feature intentions overlap; it is not a reason to silently choose one side.

1. Preview the feature branch against the current base branch.
2. If conflicts exist, report each file's base intent, feature intent, behavior impact, and resolution options.
3. Ask the user when the semantic choice is not mechanical.
4. Let the implementation worker apply the approved resolution.
5. Run the full relevant verification and compare the current feature document with the merged behavior.
6. Request explicit merge approval.

Integration for the same base branch is serialized. A successful merge does not authorize push or PR creation.
