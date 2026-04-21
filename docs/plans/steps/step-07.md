---
id: step-07
title: app-feel-visual-pass
status: completed
screen_ids: [home, search-filter-results, title-detail-top, title-detail-mid, title-detail-bottom]
visual_scope: approximate
depends_on: [step-01, step-02, step-03, step-04, step-05, step-06]
outputs:
  - `app/globals.css` — app shell max-width 430px 중앙 정렬, 세이프 에어리어 패딩, iOS 시스템 폰트, 데스크톱 프레임 배경, 상단 헤더·하단 탭·Watch Now 바에 `backdrop-filter`, 탭 아이템 44px 최소 높이, `-webkit-tap-highlight-color` 투명화, `overscroll-behavior-y: contain`
  - `app/layout.tsx` — `viewport.viewportFit = "cover"`, `interactiveWidget = "resizes-content"` 등 iOS 모바일 메타 보강
  - `tests/e2e/app-feel.spec.ts` — max-width 제한, safe area padding, 터치 타겟 44px, 데스크톱 뷰포트에서 프레임 중앙 렌더 검증 + 스크린샷
acceptance:
  - 모든 라우트의 app shell 최대 가로폭이 500px 이하로 제한됨 (계산된 `getBoundingClientRect().width`)
  - 상단 sticky 헤더와 하단 탭 바에 `backdrop-filter`가 적용됨 (computed style)
  - 하단 탭 아이템과 Watch Now 버튼이 최소 44px 높이
  - `layout.tsx`의 viewport 메타에 `viewportFit: "cover"` 포함
  - Playwright 데스크톱 뷰포트(예: 1280×800)에서 app shell이 중앙에 배치되고 좌우 여백이 생김
  - 기존 Vitest + Playwright 전체 스위트(step-01~06) 모두 그대로 통과
---

# 스텝

## 목표

PDF가 상정한 iOS 네이티브 앱 시각적 계약에 맞춰 UI 쉘을 앱스럽게 만든다. 기능이나 라우트를 건드리지 않고, 시각·레이아웃·메타만 보강한다.

## 범위 안

- `app-shell`을 `max-width: 430px` + `margin-inline: auto`로 제한하고 데스크톱 뷰포트에서 중앙 배치.
- 데스크톱 `body` 배경을 더 어두운 톤으로 두어 프레임 경계감 확보.
- `padding-top: env(safe-area-inset-top)` + `padding-bottom: env(safe-area-inset-bottom)` 반영으로 iOS Safari 상태바·홈 인디케이터 공간 확보.
- iOS 시스템 폰트 스택을 최상위로 올림(`-apple-system`, `"SF Pro Text"`, `"SF Pro Display"`, `system-ui`).
- 상단 sticky 헤더(`home-header`, `filter-header`), 하단 탭 바(`bottom-tabs`), `watch-now-bar`에 `backdrop-filter: blur(...)` + 반투명 배경.
- `-webkit-tap-highlight-color: transparent`, `touch-action: manipulation`.
- `overscroll-behavior-y: contain` — iOS 바운스 외부 스크롤 체인 차단.
- 하단 탭 아이템과 `watch-now-bar__cta` 높이 최소 44px 보장.
- `app/layout.tsx`의 `viewport` 객체에 `viewportFit: "cover"`, 필요 시 `themeColor` 유지.
- `tests/e2e/app-feel.spec.ts` 시나리오 추가로 위 수용 기준을 자동화.
- Playwright `playwright.config.ts`에 데스크톱 뷰포트 프로젝트 1개 추가(예: `desktop-1280`)로 중앙 프레임을 스크린샷.

## 범위 밖

- PWA manifest, service worker, 오프라인 동작 (Option B 영역).
- React Native 재스택 (Option A 영역).
- 신규 화면, 라우트, 데이터 변경.
- 실제 iOS 기기 실기 테스트 (세이프 에어리어/블러는 시뮬레이션과 Playwright WebKit으로 검증).
- 햅틱 피드백 모사.

## 산출물

- 갱신된 `app/globals.css`, `app/layout.tsx`, `playwright.config.ts`
- 신규 `tests/e2e/app-feel.spec.ts`
- `docs/verification/evidence/step-07/` 아래 모바일 + 데스크톱 뷰포트 스크린샷

## 승인 기준

| Criteria | Evidence Type |
| --- | --- |
| 모든 주요 라우트(`/`, `/search`, `/titles/t-08`)의 `.app-shell` 실제 렌더 폭이 ≤ 500px | test (Playwright JS eval) |
| 상단 sticky 헤더와 하단 탭 바에 `backdrop-filter` 적용(computed style에서 `none`이 아님) | test (Playwright JS eval) |
| 하단 탭 아이템 3개 모두 높이 ≥ 44px, Watch Now 버튼 높이 ≥ 44px | test (Playwright bounding rect) |
| `app/layout.tsx`의 viewport 객체가 `viewportFit: "cover"` 포함 | file-check (grep) |
| 데스크톱 뷰포트(1280×800) 스크린샷에서 app shell이 중앙에 배치 | test + manual |
| 기존 Vitest 43건 + Playwright 16건 전체 통과 유지 | test |
