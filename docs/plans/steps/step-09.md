# Step 09 — Magazine + Profile + Wishlist

## Summary

Build the magazine listing, user profile dashboard, and wishlist pages with their respective interactive features and demo data.

## Scope

- In Scope: /magazine (masthead, cover story, 7 category filter, 8 article grid with size variants, 3 columns, newsletter form placeholder), /profile (hero with tier, 8-tab dashboard with demo data for all tabs), /wishlist (sort, grid, remove, add to cart, days-ago badge, empty state)
- Out of Scope: real newsletter, real auth, real order processing

## Outputs

- app/magazine/page.tsx
- app/profile/page.tsx
- app/wishlist/page.tsx
- Related components for each page

## Acceptance

1. Magazine category filter filters the 8 article grid correctly (evidence: test)
2. Article grid renders size variants in 3-column layout (evidence: manual)
3. Profile 8 tabs switch correctly and display demo data (evidence: test)
4. Wishlist add/remove works and updates the wishlist store (evidence: test)
5. Wishlist shows days-ago badge and empty state when cleared (evidence: manual)
6. Playwright E2E passes (evidence: command)

## Dependencies

- depends_on: step-02, step-03

## Visual

- screen_ids: V-05, V-06, V-10
- visual_scope: approximate
