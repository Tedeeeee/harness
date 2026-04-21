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
  "step-03"
);

test.describe("Home screen", () => {
  test("renders three curated sections in order", async ({ page }) => {
    await page.goto("/");
    const labels = await page
      .locator("[data-testid^=section-] .poster-section__label")
      .allTextContents();
    expect(labels).toEqual(["업데이트된 신작", "인기작 픽", "코리아 픽"]);

    await page.screenshot({
      path: path.join(EVIDENCE_DIR, "home-sections.png"),
      fullPage: true,
    });
  });

  test("survey banner opens externally with survey URL", async ({ page }) => {
    await page.goto("/");
    const banner = page.getByTestId("survey-banner-home");
    await expect(banner).toBeVisible();
    await expect(banner).toHaveAttribute("target", "_blank");
    const href = await banner.getAttribute("href");
    expect(href).toMatch(/^https?:\/\//);
  });

  test("bottom tab bar shows exactly Home/Event/Board without Account", async ({
    page,
  }) => {
    await page.goto("/");
    const items = page.locator('[data-testid="bottom-tabs"] [data-testid^=tab-]');
    await expect(items).toHaveCount(3);
    await expect(items.nth(0)).toHaveAttribute("data-testid", "tab-home");
    await expect(items.nth(1)).toHaveAttribute("data-testid", "tab-event");
    await expect(items.nth(2)).toHaveAttribute("data-testid", "tab-board");
    await expect(
      page.locator('[data-testid="bottom-tabs"] >> text=Account')
    ).toHaveCount(0);

    await page.screenshot({
      path: path.join(EVIDENCE_DIR, "home-bottom-tabs.png"),
      fullPage: false,
    });
  });

  test("Event tab navigates to /search", async ({ page }) => {
    await page.goto("/");
    await page.getByTestId("tab-event").click();
    await expect(page).toHaveURL(/\/search/);
  });
});
