# Step 04 — Home Screen

## Summary

Build the home page with all six sections: Hero, Flagships, Advantages, BestSellers, Reviews, and LaunchBanner.

## Scope

- In Scope: app/page.tsx (Home), Hero section (interactive keyboard visualization, switch type selector, marquee banner), Flagships (3 product cards), Advantages (4 features grid), BestSellers (8 products + category filter + sort), Reviews (4 testimonials), LaunchBanner (countdown timer, pre-order CTA)
- Out of Scope: other pages, search, actual product navigation

## Outputs

- app/page.tsx
- components/Hero.tsx
- components/Flagships.tsx
- components/Advantages.tsx
- components/BestSellers.tsx
- components/Reviews.tsx
- components/LaunchBanner.tsx

## Acceptance

1. All 6 sections render in correct order on the home page (evidence: manual)
2. BestSellers category filter filters products correctly (evidence: test)
3. BestSellers sort changes product order (evidence: test)
4. Countdown timer ticks down in real time (evidence: manual)
5. Playwright screenshot captured (evidence: file-check)

## Dependencies

- depends_on: step-02, step-03

## Visual

- screen_ids: V-01
- visual_scope: approximate
