# Step 06 — Product Detail

## Summary

Build the product detail page with image gallery, variant and switch selectors, add-to-cart flow, and tabbed content sections.

## Scope

- In Scope: /products/[id] route, 4-view gallery with thumb selection, variant (colorway) selector with sold-out state, switch selector with specs, qty stepper + total, add to cart + success feedback, tabs (details with highlights + box contents, specs table, reviews summary + 4 cards, shipping policy), breadcrumb
- Out of Scope: real payment, actual review submission

## Outputs

- app/products/[id]/page.tsx
- components/ProductGallery.tsx
- components/VariantSelector.tsx
- components/SwitchSelector.tsx
- components/ProductTabs.tsx

## Acceptance

1. Gallery thumb selection switches the main image across all 4 views (evidence: test)
2. Variant selection works and sold-out variants are visually disabled (evidence: manual)
3. Add to cart updates the cart store and shows success feedback (evidence: test)
4. All 4 tabs render correctly with their respective content (evidence: manual)
5. Breadcrumb displays correct navigation path (evidence: manual)
6. Playwright E2E passes (evidence: command)

## Dependencies

- depends_on: step-02, step-03

## Visual

- screen_ids: V-03
- visual_scope: approximate
