# Prototype Input Upgrade Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade the harness so prototype code outputs are analyzed as requirements-draft inputs without breaking the existing docs-first pipeline.

**Architecture:** Keep the current pipeline and skill names. Extend input-analysis contracts, then tighten the requirements-promotion and technical-approach handoff rules so product intent and demo implementation are separated.

**Tech Stack:** Markdown skill docs, markdown templates, root harness guidance docs

---

## Chunk 1: Input Analysis Contract

### Task 1: Update `analyze-visual-source` skill contract

**Files:**
- Modify: `skills/analyze-visual-source/SKILL.md`

- [ ] Step 1: Expand accepted input types to include HTML/JSX/CSS prototype code bundles.
- [ ] Step 2: Add route/data/interaction/token extraction requirements for prototype-code inputs.
- [ ] Step 3: Add confidence tags and source reference rules.
- [ ] Step 4: Preserve the hard-stop and inventory-first behavior.

### Task 2: Upgrade the visual analysis template

**Files:**
- Modify: `templates/visual-source-analysis-template.md`

- [ ] Step 1: Keep the existing screen inventory contract intact.
- [ ] Step 2: Add sections for interaction inventory, data/entity signals, token signals, and prototype-only notes.
- [ ] Step 3: Add confidence/source-ref expectations to the template wording.

## Chunk 2: Requirements And Approach Handoff

### Task 3: Update requirements authoring rules

**Files:**
- Modify: `skills/author-product-requirements/SKILL.md`
- Modify: `templates/product-requirements-template.md`

- [ ] Step 1: Teach the skill to read confidence-tagged analysis results.
- [ ] Step 2: Define promotion rules for `explicit`, `inferred`, `demo-suspect`, and `needs-confirm`.
- [ ] Step 3: Add template space for prototype-derived notes and unresolved confirmation items.

### Task 4: Update technical approach rules

**Files:**
- Modify: `skills/select-technical-approach/SKILL.md`
- Modify: `templates/technical-approach-template.md`

- [ ] Step 1: Clarify that implementation delta decisions happen here, not in input analysis.
- [ ] Step 2: Add explicit questions about what to preserve, replace, or reinterpret from the prototype.
- [ ] Step 3: Add template wording for prototype reuse/rewrite decisions.

## Chunk 3: Router And Root Guidance

### Task 5: Update router and root documentation

**Files:**
- Modify: `skills/route-self-harness/SKILL.md`
- Modify: `README.md`
- Modify: `CLAUDE.md`
- Modify: `docs/README.md`

- [ ] Step 1: Update routing language so prototype code inputs are handled by the same analysis stage.
- [ ] Step 2: Update root guidance to describe prototype code as requirements-draft input.
- [ ] Step 3: Keep the docs-first and stage-gated structure unchanged.

### Task 6: Record the upgrade for future sessions

**Files:**
- Modify: `research/changelog.md`
- Modify: `research/roadmap.md`

- [ ] Step 1: Add a note that the harness now formally supports prototype-code analysis.
- [ ] Step 2: Capture any remaining future work around automation/parsers as roadmap items.

## Chunk 4: Verification

### Task 7: Verify wording consistency

**Files:**
- Review only: modified markdown files

- [ ] Step 1: Re-read modified files to ensure terminology is consistent.
- [ ] Step 2: Confirm the pipeline remains unchanged.
- [ ] Step 3: Confirm prototype code is treated as requirements-draft input, not final implementation contract.
