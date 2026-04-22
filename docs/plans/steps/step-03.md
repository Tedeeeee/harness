# Step 03 — Global Layout + Nav + Footer + Cart Drawer

## Summary

Build the global layout shell including sticky navigation, footer, and slide-out cart drawer with Zustand-powered cart and wishlist stores.

## Scope

- In Scope: layout.tsx with Zustand providers, Nav (sticky, announcement strip, menu 7 items, search/wishlist/profile/theme/cart icons, scroll backdrop blur, mobile responsive), Footer (newsletter form placeholder, social links, sitemap, legal), CartDrawer (460px slide panel, items list, qty adjust, subtotal/shipping/total, checkout button, empty state)
- Out of Scope: page content, search functionality, actual checkout

## Outputs

- app/layout.tsx
- components/Nav.tsx
- components/Footer.tsx
- components/CartDrawer.tsx
- cart store (Zustand)
- wishlist store (Zustand)

## Acceptance

1. Nav renders with all 7 menu items and all icons (evidence: manual)
2. Theme toggle works across pages (evidence: manual)
3. CartDrawer opens and closes correctly, shows empty state when no items (evidence: manual)
4. Footer renders with newsletter placeholder, social links, sitemap, and legal (evidence: manual)
5. Playwright screenshot captured (evidence: file-check)

## Dependencies

- depends_on: step-01, step-02

## Visual

- screen_ids: V-11
- visual_scope: approximate
