# Step 02 — Data Model and Seed

## Summary

Define all TypeScript types and seed data ported from the prototype, plus accessor, filter, and sort functions with unit tests.

## Scope

- In Scope: src/data/ with types (Product, Keycap, Switch, Accessory, Bundle, Article, Review, User, Order, Coupon), seed data ported from prototype (12 keyboards, 12 keycaps, 6 switches, 14 accessories, 3 bundles, 8 articles, 4 reviews), filter options, home-sections.ts, accessor/filter/sort functions
- Out of Scope: UI, API, components

## Outputs

- src/data/*.ts files (types, seed data, accessors, filters, sorting)
- Vitest unit tests for accessors, filters, and sorting

## Acceptance

1. All types defined and exported (evidence: file-check)
2. Seed data matches prototype counts — 12 keyboards, 12 keycaps, 6 switches, 14 accessories, 3 bundles, 8 articles, 4 reviews (evidence: test)
3. Filter AND logic works correctly across multiple criteria (evidence: test)
4. Sort comparators produce correct ordering (evidence: test)
5. Vitest passes with zero failures (evidence: command)

## Dependencies

- depends_on: step-01

## Visual

- screen_ids: none
- visual_scope: not-applicable
