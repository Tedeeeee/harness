# Step 03 Verification — Global Layout + Nav + Footer + Cart Drawer

## Summary

글로벌 레이아웃(Nav/Footer/CartDrawer) + Zustand cart/wishlist 스토어 구현.

## Acceptance Results

| # | Criterion | Result | Evidence |
|---|-----------|--------|----------|
| 1 | Nav 렌더 (메뉴 7종 + 아이콘) | pass | Playwright `Nav renders with menu items and icons` |
| 2 | 테마 토글 Nav에서 동작 | pass | Playwright `theme toggle works from Nav` |
| 3 | CartDrawer 열기/닫기 | pass | Playwright `cart drawer opens and closes` |
| 4 | Footer 렌더 | pass | Playwright `Footer renders with newsletter and links` |
| 5 | 스크린샷 캡처 | pass | `tests/e2e/evidence/layout-desktop.png` |

## Test Results

- Vitest: 38/38 passed
- Playwright (desktop): 9/9 passed

## Evidence Files

- `C:\study\my-new-project\tests\e2e\evidence\layout-desktop.png`

## Result

- **pass**
