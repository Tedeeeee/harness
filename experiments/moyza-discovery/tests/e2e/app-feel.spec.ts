import { test, expect } from "@playwright/test";
import path from "node:path";

const EVIDENCE_DIR = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "..",
  "docs",
  "verification",
  "evidence",
  "step-07"
);

const ROUTES = ["/", "/search", "/titles/t-08"];

test.describe("App-feel visual pass", () => {
  test("app-shell is constrained to a phone-width frame on every route", async ({
    page,
  }, testInfo) => {
    for (const route of ROUTES) {
      await page.goto(route);
      const shell = page.locator(".app-shell");
      const box = await shell.boundingBox();
      expect(box, `app-shell box for ${route}`).not.toBeNull();
      expect(box!.width).toBeLessThanOrEqual(500);
    }
    const device = testInfo.project.name;
    await page.goto("/");
    await page.screenshot({
      path: path.join(EVIDENCE_DIR, `home-${device}.png`),
      fullPage: true,
    });
    await page.goto("/titles/t-08");
    await page.screenshot({
      path: path.join(EVIDENCE_DIR, `detail-${device}.png`),
      fullPage: true,
    });
  });

  test("sticky header and bottom tab bar use backdrop-filter", async ({
    page,
  }) => {
    await page.goto("/");
    for (const selector of [".home-header", ".bottom-tabs"]) {
      const filterValue = await page
        .locator(selector)
        .evaluate((el) => {
          const style = window.getComputedStyle(el);
          return (
            style.getPropertyValue("backdrop-filter") ||
            style.getPropertyValue("-webkit-backdrop-filter")
          );
        });
      expect(
        filterValue && filterValue !== "none",
        `${selector} should have backdrop-filter`
      ).toBeTruthy();
    }
  });

  test("bottom tab items and Watch Now button have 44px+ touch targets", async ({
    page,
  }) => {
    await page.goto("/");
    const items = page.locator('[data-testid="bottom-tabs"] [data-testid^=tab-]');
    const count = await items.count();
    for (let i = 0; i < count; i += 1) {
      const box = await items.nth(i).boundingBox();
      expect(box!.height).toBeGreaterThanOrEqual(44);
    }

    await page.goto("/titles/t-08");
    const cta = page.getByTestId("watch-now-link");
    const ctaBox = await cta.boundingBox();
    expect(ctaBox!.height).toBeGreaterThanOrEqual(44);
  });

  test("bottom tab bar is pinned to app-shell bottom on Home", async ({
    page,
  }) => {
    await page.goto("/");
    const shell = page.locator(".app-shell");
    const bar = page.getByTestId("bottom-tabs");
    await expect(bar).toBeInViewport();
    const shellBox = await shell.boundingBox();
    const barBox = await bar.boundingBox();
    expect(shellBox).not.toBeNull();
    expect(barBox).not.toBeNull();
    const shellBottom = shellBox!.y + shellBox!.height;
    const barBottom = barBox!.y + barBox!.height;
    expect(Math.abs(shellBottom - barBottom)).toBeLessThan(4);
  });

  test("Watch Now bar is pinned to app-shell bottom on detail", async ({
    page,
  }) => {
    await page.goto("/titles/t-08");
    const shell = page.locator(".app-shell");
    const bar = page.getByTestId("watch-now-bar");
    await expect(bar).toBeInViewport();
    const shellBox = await shell.boundingBox();
    const barBox = await bar.boundingBox();
    const shellBottom = shellBox!.y + shellBox!.height;
    const barBottom = barBox!.y + barBox!.height;
    expect(Math.abs(shellBottom - barBottom)).toBeLessThan(4);
  });

  test("desktop viewport centers the app-shell with side margin", async ({
    page,
  }, testInfo) => {
    test.skip(
      testInfo.project.name !== "desktop-1280",
      "centering check only meaningful on desktop viewport"
    );
    await page.goto("/");
    const shell = page.locator(".app-shell");
    const box = await shell.boundingBox();
    expect(box).not.toBeNull();
    const viewport = page.viewportSize();
    const leftGap = box!.x;
    const rightGap = viewport!.width - (box!.x + box!.width);
    expect(leftGap).toBeGreaterThan(100);
    expect(rightGap).toBeGreaterThan(100);
    expect(Math.abs(leftGap - rightGap)).toBeLessThan(12);

    await page.screenshot({
      path: path.join(EVIDENCE_DIR, "desktop-centered.png"),
      fullPage: true,
    });
  });
});
