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
  "step-04"
);

test.describe("Search + Filter screen", () => {
  test("Event tab lands on /search with default results", async ({ page }) => {
    await page.goto("/");
    await page.getByTestId("tab-event").click();
    await expect(page).toHaveURL(/\/search/);
    await expect(page.getByTestId("results-grid")).toBeVisible();
    const count = await page.getByTestId("results-count").textContent();
    expect(Number(count)).toBeGreaterThan(0);
    await page.screenshot({
      path: path.join(EVIDENCE_DIR, "search-initial.png"),
      fullPage: true,
    });
  });

  test("toggling country + genre + platform narrows results", async ({ page }) => {
    await page.goto("/search");
    const initial = Number(await page.getByTestId("results-count").textContent());
    await page.getByTestId("filter-country-Korea").click();
    await page.getByTestId("filter-genre-Romance").click();
    await page.getByTestId("filter-platform-A").click();
    const narrowed = Number(await page.getByTestId("results-count").textContent());
    expect(narrowed).toBeLessThan(initial);
    await page.screenshot({
      path: path.join(EVIDENCE_DIR, "search-narrowed.png"),
      fullPage: true,
    });
  });

  test("result cards link to /titles/{id}", async ({ page }) => {
    await page.goto("/search");
    const firstCard = page.getByTestId("result-card").first();
    const href = await firstCard.getAttribute("href");
    expect(href).toMatch(/^\/titles\/t-\d{2}$/);
  });

  test("platform chips render as text-only (no pill background)", async ({
    page,
  }) => {
    await page.goto("/search");
    const platformChip = page.getByTestId("filter-platform-A");
    const className = (await platformChip.getAttribute("class")) ?? "";
    expect(className).toContain("chip--text");
    expect(className).not.toContain("chip--pill");
  });

  test("initial keyword from URL is applied", async ({ page }) => {
    await page.goto("/search?q=%EB%A0%88%EC%9D%B4%EB%94%94");
    const input = page.getByRole("searchbox", { name: /search titles/i });
    await expect(input).toHaveValue("레이디");
    const count = Number(await page.getByTestId("results-count").textContent());
    expect(count).toBeGreaterThan(0);
  });
});
