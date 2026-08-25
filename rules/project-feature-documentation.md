# Project Feature Documentation

The target project owns the current implementation document. The harness supplies the rule and template; it does not store feature history or runtime transcripts.

## Location

Use the target project's existing documentation convention. If none exists, use:

    docs/features/<feature-id>.md

The path may be configured by the project. Do not create .harness/runs/ or another permanent orchestration-history directory.

## Contents

The document describes the feature as it works now:

- purpose and user-visible behavior;
- processing flow and state changes;
- business rules and edge cases;
- API, UI, data, permission, and external contracts;
- affected modules and operational concerns;
- verification commands and expected evidence.

Do not add agent transcripts, rejected alternatives, model names, phase handoffs, timestamps, or a chronological implementation diary.

## Lifecycle

Implementation updates the document when behavior changes. Verification compares the document with the code and tests. Merge is not complete while the document is missing or materially stale.
