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
  "step-06"
);

test.describe("End-to-end regression", () => {
  test("Home → Search → Detail → Watch Now → Back → Board", async ({ page }) => {
    // 1. Home 상단 설문 베너 확인 (href + target)
    await page.goto("/");
    const homeBanner = page.getByTestId("survey-banner-home");
    await expect(homeBanner).toBeVisible();
    await expect(homeBanner).toHaveAttribute("target", "_blank");
    await page.screenshot({
      path: path.join(EVIDENCE_DIR, "regression-01-home.png"),
      fullPage: true,
    });

    // 2. Event 탭으로 검색 화면 진입
    await page.getByTestId("tab-event").click();
    await expect(page).toHaveURL(/\/search/);
    await expect(page.getByTestId("results-grid")).toBeVisible();
    await page.screenshot({
      path: path.join(EVIDENCE_DIR, "regression-02-search.png"),
      fullPage: true,
    });

    // 3. 필터 칩 조합 후 결과 카드 → 상세 진입
    await page.getByTestId("filter-country-Korea").click();
    const card = page.getByTestId("result-card").first();
    const href = (await card.getAttribute("href")) ?? "";
    expect(href).toMatch(/^\/titles\/t-\d{2}$/);
    await card.click();
    await expect(page).toHaveURL(new RegExp(href.replace(/\//g, "\\/")));

    // 4. 상세의 Watch Now 확인
    const link = page.getByTestId("watch-now-link");
    await expect(link).toHaveAttribute("target", "_blank");
    const externalHref = (await link.getAttribute("href")) ?? "";
    expect(externalHref).toMatch(/^https?:\/\//);
    await page.screenshot({
      path: path.join(EVIDENCE_DIR, "regression-03-detail.png"),
      fullPage: true,
    });

    // 5. 뒤로가기 → 검색 화면으로 복귀
    await page.getByTestId("detail-back").click();
    await expect(page).toHaveURL(/\/search/);

    // 6. Home 탭으로 복귀
    await page.getByTestId("tab-home").click();
    await expect(page).toHaveURL(/\/$/);

    // 7. Board 탭 설문 링크 확인 (외부 URL, target=_blank)
    const board = page.getByTestId("tab-board");
    await expect(board).toHaveAttribute("target", "_blank");
    const boardHref = (await board.getAttribute("href")) ?? "";
    expect(boardHref).toMatch(/^https?:\/\//);
    await page.screenshot({
      path: path.join(EVIDENCE_DIR, "regression-04-board.png"),
      fullPage: false,
    });
  });
});
