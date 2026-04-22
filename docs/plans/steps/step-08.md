# Step 08 — Keycaps + Switches + Accessories

## Summary

Build the keycaps, switches, and accessories catalog pages with their specialized filters, comparison features, and visualization components.

## Scope

- In Scope: /keycaps (profile filter, height comparison visualization, 12 keycap grid, sort, guide editorial), /switches (type filter, compare max 3, force curve visualization, travel visualization, sound profile waveform display, 6 switch table), /accessories (category chips, 14 items magazine grid with big cards every 7th, 3 bundle sets)
- Out of Scope: audio playback, actual purchase flow

## Outputs

- app/keycaps/page.tsx
- app/switches/page.tsx
- app/accessories/page.tsx
- Related components for each page (filters, visualizations, grids)

## Acceptance

1. Keycap profile filter correctly filters the 12 keycap grid (evidence: test)
2. Switch compare selects a maximum of 3 switches (evidence: test)
3. Force curve visualization renders for selected switches (evidence: manual)
4. Accessories category filter works and bundles display correctly (evidence: test)
5. Magazine grid shows big cards at every 7th position (evidence: manual)
6. Playwright E2E passes (evidence: command)

## Dependencies

- depends_on: step-02, step-03

## Visual

- screen_ids: V-07, V-08, V-09
- visual_scope: approximate
