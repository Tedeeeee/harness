# Step 10 — Finalize + Regression + Visual Pass

## Summary

Run full E2E regression across all 11 screens, verify theme and responsive behavior, document placeholders, and finalize project documentation.

## Scope

- In Scope: E2E regression suite across all 11 screens, theme toggle verification on every page, responsive check (1280px + 375px), cross-page navigation flow, placeholder documentation (payment, newsletter, auth swap points), README.md + CLAUDE.md final, dead link check
- Out of Scope: new features, new screens

## Outputs

- tests/e2e/regression.spec.ts
- Updated README.md
- Updated CLAUDE.md
- docs/verification/step-10-verification.md

## Acceptance

1. All existing Vitest unit tests pass with zero failures (evidence: command)
2. All Playwright E2E tests pass with zero failures (evidence: command)
3. Theme toggle works on all pages in both light and dark modes (evidence: test)
4. Responsive screenshots captured at 1280px and 375px for all pages (evidence: file-check)
5. README.md documents project setup, scripts, and placeholder swap points (evidence: file-check)
6. No dead links found across all navigation paths (evidence: test)

## Dependencies

- depends_on: step-01, step-02, step-03, step-04, step-05, step-06, step-07, step-08, step-09

## Visual

- screen_ids: V-01, V-02, V-03, V-04, V-05, V-06, V-07, V-08, V-09, V-10, V-11
- visual_scope: approximate
