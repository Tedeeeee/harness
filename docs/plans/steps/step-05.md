# Step 05 — Catalog + Search

## Summary

Build the catalog page with sidebar filters, sort, view toggle, pagination, and keyword search overlay.

## Scope

- In Scope: /catalog route, sidebar filters (layout/switch/body/price, multi-select, AND logic), active filter chips with remove, 6 sort options, grid/list view toggle, 12 products, pagination, empty state, keyword search (Nav search icon opens search overlay or /search route)
- Out of Scope: product detail page, cart integration

## Outputs

- app/catalog/page.tsx
- components/CatalogFilters.tsx
- components/CatalogGrid.tsx
- components/SearchOverlay.tsx or app/search/page.tsx

## Acceptance

1. 4-criteria filter works correctly with AND logic (evidence: test)
2. Sort changes product order across all 6 options (evidence: test)
3. View toggle switches between grid and list layout (evidence: manual)
4. Search finds products by keyword (evidence: test)
5. Empty state displays when no products match filters (evidence: manual)
6. Playwright E2E passes (evidence: command)

## Dependencies

- depends_on: step-02, step-03

## Visual

- screen_ids: V-02
- visual_scope: approximate
