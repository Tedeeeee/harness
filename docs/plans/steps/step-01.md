# Step 01 — Project Scaffold

## Summary

Bootstrap the Next.js App Router project with TypeScript, Tailwind CSS, Zustand, testing infrastructure, and dark/light theme toggle.

## Scope

- In Scope: create-next-app in C:\study\my-new-project, App Router + TypeScript + Tailwind CSS, dev server on port 3333, prototype CSS variables in globals.css (light + dark mode), Zustand setup (theme store), Vitest + Playwright (Desktop Chromium 1280x720 + Mobile 375px), dark/light theme toggle basic functionality
- Out of Scope: any page content, data, components beyond bare layout

## Outputs

- package.json
- tailwind.config.ts
- globals.css with CSS variables (light + dark)
- theme store (Zustand)
- vitest.config.ts
- playwright.config.ts
- README.md
- CLAUDE.md

## Acceptance

1. Dev server runs on port 3333 (evidence: command)
2. Theme toggle switches between light and dark mode (evidence: manual)
3. Vitest passes with zero failures (evidence: command)
4. Playwright screenshot captured for both desktop and mobile viewports (evidence: file-check)

## Dependencies

- depends_on: none

## Visual

- screen_ids: none
- visual_scope: not-applicable
