---
name: route-self-harness
description: Use when the harness must decide the next owner or skill by interpreting the current prompt together with live document state across requirements, source analysis, planning, implementation, verification, and project closure.
---

# Route Self Harness

## Overview

This skill is the harness traffic controller.

It does not do the work itself. It decides which skill must run next.

## Read These First

- `CLAUDE.md`
- `README.md`
- `docs/state-model.md`
- `docs/document-lifecycle.md`
- `docs/plans/planning-state.md` if it exists
- `docs/implementation/implementation-state.md` if it exists
- `memory/harness-memory.md` (feedback 카테고리는 라우팅 판정에 직접 영향)
- `memory/project-memory.md` if it exists

Memory를 읽은 직후 `append_trace(event_type="memory-read", actor="route-self-harness", reason=...)`로 한 줄 기록합니다. reason은 어떤 memory 항목이 현재 판정에 영향을 주었는지 요약 (또는 "no applicable memory").

## Core Rule

Always route using `prompt + state`, never prompt alone.

## Decision Order

1. Check whether the previous project is already complete and a transition is required
2. Check whether the current request is driven by a visual or prototype source of truth
3. Check whether requirements authoring is still missing
4. Check planning state
5. Check implementation state
6. Check verification and blocker state
7. Choose exactly one next skill

## Routing Rules

### Project closure

- If implementation is done and a retrospective is still missing -> `project-retrospective`
- If implementation is done and the user is starting new work -> `project-transition`

### Visual source mode

- If the request is mainly driven by a PDF, mockup, screenshot set, wireframe, interactive prototype, or prototype code bundle and `docs/visual-analysis/visual-source-analysis.md` does not exist -> `analyze-visual-source`
- If visual analysis exists but a requirements document does not yet exist -> `author-product-requirements`

### Planning with `planning-state.md`

- If `source-analysis` is `not-started` and the request is visual-source or prototype-source driven -> `analyze-visual-source`
- If `source-analysis` is `blocked` -> `author-product-requirements` only after the blocking question is resolved
- If requirements are missing -> `author-product-requirements`
- If requirements are present and `requirements` is `not-assessed` -> `assess-product-requirements`
- If technical approach is `not-started` -> `select-technical-approach`
- If interview is `not-started` or `blocked` -> `conduct-development-interview`
- If master plan is `not-started` -> `generate-master-plan`
- If step docs are `not-started` -> `generate-step-docs`

### Planning fallback without `planning-state.md`

- If the request is visual-source or prototype-source driven and there is no visual analysis document -> `analyze-visual-source`
- If requirements are missing -> `author-product-requirements`
- If requirements exist but have not been assessed -> `assess-product-requirements`
- If technical approach is missing -> `select-technical-approach`
- If interview decisions are missing -> `conduct-development-interview`
- If master plan is missing -> `generate-master-plan`
- If step docs are missing -> `generate-step-docs`

### Implementation

- If step docs exist but no active step exists -> `implementation-start`
- If current step is `in_progress` -> `implement-current-step`
- If current step is `verification-ready` -> `verify-current-step`
- If current state is `blocked` -> `implementation-blocker`
- If current state is `interrupted_by_user` -> `implement-current-step` (with interrupt handling branch)

### Completion

- If all steps are done -> `project-retrospective`

## Strong Rules

- Do not jump from raw visual or prototype input directly into requirements or implementation
- Do not skip planning stages aggressively
- Do not treat every "continue" prompt literally; interpret it through state
- If the task is visual-source or prototype-source driven, source analysis must exist before requirements authoring begins

## Output

- The name of the next skill
- A short reason grounded in current state

## Trace

After choosing the next skill, append one trace entry to the current day's trace file per `templates/trace-entry-template.md`:

- event_type: `skill-selected`
- actor: `route-self-harness`
- reason: short state-grounded reason (e.g., "requirements not-assessed")
- detail: chosen skill name

This entry is for debugging only and does not substitute verification evidence.

## Success Condition

The harness chooses the correct next owner without skipping the source analysis, planning, implementation, or verification contracts.
