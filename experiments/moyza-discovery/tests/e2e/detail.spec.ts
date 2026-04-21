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
  "step-05"
);

const DETAIL_URL = "/titles/t-08"; // 레이디 두아

test.describe("Title detail screen", () => {
  test("renders hero, tabs, sections, and Watch Now bar", async ({ page }) => {
    await page.goto(DETAIL_URL);
    await expect(page.getByTestId("detail-hero")).toBeVisible();
    await expect(page.getByTestId("detail-tabs")).toBeVisible();
    await expect(page.getByTestId("synopsis-panel")).toBeVisible();
    await expect(page.getByTestId("cast-list")).toBeVisible();
    await expect(page.getByTestId("similar-section")).toBeVisible();
    await expect(page.getByTestId("watch-now-bar")).toBeVisible();

    await page.screenshot({
      path: path.join(EVIDENCE_DIR, "detail-top.png"),
      fullPage: false,
    });
  });

  test("no share icon in top bar, no heart icon in bottom bar", async ({
    page,
  }) => {
    await page.goto(DETAIL_URL);
    const hero = page.getByTestId("detail-hero");
    await expect(hero.getByLabel("Share")).toHaveCount(0);
    const bar = page.getByTestId("watch-now-bar");
    const textContent = (await bar.textContent()) ?? "";
    expect(textContent.includes("❤")).toBe(false);
    expect(textContent.includes("♥")).toBe(false);
  });

  test("Watch Now href points to externalUrl and opens in new tab", async ({
    page,
  }) => {
    await page.goto(DETAIL_URL);
    const link = page.getByTestId("watch-now-link");
    await expect(link).toHaveAttribute("target", "_blank");
    await expect(link).toHaveAttribute(
      "href",
      /https:\/\/example\.invalid\/watch\/t-08/
    );
  });

  test("platform badges hidden when flag is default", async ({ page }) => {
    await page.goto(DETAIL_URL);
    await expect(page.getByTestId("platform-badges")).toHaveCount(0);
  });

  test("Cast list items show name-only (no Lead Cast labels)", async ({
    page,
  }) => {
    await page.goto(DETAIL_URL);
    const items = page.getByTestId("cast-item");
    const texts = await items.allInnerTexts();
    for (const t of texts) {
      expect(/lead cast/i.test(t)).toBe(false);
      expect(/supporting/i.test(t)).toBe(false);
    }
  });

  test("captures three scroll states for evidence", async ({ page }) => {
    await page.goto(DETAIL_URL);
    // top
    await page.screenshot({
      path: path.join(EVIDENCE_DIR, "detail-top-scroll.png"),
      fullPage: false,
    });
    // expand synopsis to get the meta table
    await page.getByTestId("synopsis-more").click();
    await page.evaluate(() => window.scrollTo(0, 400));
    await page.screenshot({
      path: path.join(EVIDENCE_DIR, "detail-mid-scroll.png"),
      fullPage: false,
    });
    // scroll further to Cast / Similar
    await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
    await page.screenshot({
      path: path.join(EVIDENCE_DIR, "detail-bottom-scroll.png"),
      fullPage: false,
    });
  });
});
