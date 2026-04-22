# Step 07 — Cart + Checkout Placeholder

## Summary

Build the full cart page with item management, shipping/gift options, promo code validation, order summary, and a checkout placeholder page.

## Scope

- In Scope: /cart route, progress steps (3 stages), select all/individual checkboxes, qty adjust, shipping method (standard/express), gift wrap toggle, promo code input + validation, order summary (subtotal/discount/shipping/wrap/total/points), free shipping progress bar, payment method badges, recommended products 3, checkout placeholder page (/checkout with "준비 중" message)
- Out of Scope: real payment, real promo server validation

## Outputs

- app/cart/page.tsx
- app/checkout/page.tsx
- components/CartItem.tsx
- components/OrderSummary.tsx
- components/PromoCode.tsx

## Acceptance

1. Checkbox selection (select all / individual) works correctly (evidence: test)
2. Qty changes recalculate subtotal, shipping, and total (evidence: test)
3. Promo code KEYBODER10 gives 10% discount (evidence: test)
4. Shipping method and gift wrap options update the total correctly (evidence: test)
5. Checkout button redirects to placeholder page with "준비 중" message (evidence: manual)
6. Playwright E2E passes (evidence: command)

## Dependencies

- depends_on: step-02, step-03, step-06

## Visual

- screen_ids: V-04
- visual_scope: approximate
