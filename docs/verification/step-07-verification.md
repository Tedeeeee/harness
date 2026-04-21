# 스텝 검증

## 메타데이터

- Step: step-07
- Title: app-feel-visual-pass
- Verification Date: 2026-04-20
- Result: pass
- Verification Doc Filename: `step-07-verification.md`

## 승인 기준 체크리스트

| Item | Expected | Evidence | Result |
| --- | --- | --- | --- |
| 1 | 모든 주요 라우트(`/`, `/search`, `/titles/t-08`)의 app-shell 폭 ≤ 500px | Playwright `app-shell is constrained to a phone-width frame on every route` pass (iPhone/desktop 두 프로파일). 실측값은 iPhone 프로파일 390px, 데스크톱 430px. | pass |
| 2 | 상단 sticky 헤더와 하단 탭 바에 `backdrop-filter` 적용 | Playwright `sticky header and bottom tab bar use backdrop-filter` pass. computed `backdrop-filter`가 `none`이 아님(양쪽 프로파일). | pass |
| 3 | 하단 탭 아이템과 Watch Now 버튼 높이 ≥ 44px | Playwright `bottom tab items and Watch Now button have 44px+ touch targets` pass. `bounding-box.height`가 모두 44 이상. | pass |
| 4 | `layout.tsx`에 `viewportFit: "cover"` 포함 | `experiments/moyza-discovery/app/layout.tsx`의 `export const viewport` 객체에 `viewportFit: "cover"` 추가 확인. `grep`으로 검증 가능. | pass |
| 5 | 데스크톱 뷰포트(1280×800)에서 app shell이 중앙 배치 | Playwright `desktop viewport centers the app-shell with side margin` pass — 좌우 여백 차 < 12px, 각 여백 > 100px. 스크린샷 `desktop-centered.png`. | pass |
| 6 | 기존 Vitest 43건 + Playwright 회귀·기능 스위트 그대로 통과 | Vitest 43/43 pass. Playwright 23/23 pass + 1 의도된 skip(iphone 프로파일에서 데스크톱 전용 테스트 skip). | pass |

## 테스트

- Commands Run:
  - `npm run typecheck` → exit 0
  - `npm run test` → 43/43 pass. 로그: `docs/verification/evidence/step-07/vitest.log`
  - `npx playwright test` → 23 passed, 1 skipped (의도된 desktop-only skip on iphone 프로파일). 로그: `docs/verification/evidence/step-07/playwright.log`
- Result: all pass
- Notes:
  - iPhone 프로파일에서도 위치·폭 검증을 같은 스펙에서 돌려 앱 shell이 모바일/데스크톱 공통으로 430px 이하로 제한됨을 확인.
  - 데스크톱 프로파일은 WebKit 대신 Chromium 사용(`Desktop Chrome`) — 이미 설치된 webkit과 병행.

## 수동 검증

- Check Performed:
  - 스크린샷 5장(`home-iphone-13-portrait.png`, `detail-iphone-13-portrait.png`, `home-desktop-1280.png`, `detail-desktop-1280.png`, `desktop-centered.png`)을 PDF와 대조.
  - iPhone 뷰포트: 상단 헤더·하단 탭이 반투명 + 블러. 탭 바와 Watch Now 바가 세이프 에어리어 아래 확장되어 네이티브 앱 느낌.
  - 데스크톱 뷰포트: 430px 폭 프레임이 중앙 배치, 주변 다크 그라디언트 + 프레임 라운드 40px + 부드러운 그림자. PDF의 iPhone 목업과 시각적으로 유사.
- Result: pass
- Notes:
  - `env(safe-area-inset-*)`은 Playwright 시뮬레이션에서는 0으로 계산되지만 실제 iOS Safari에서 자동 채워짐. 수용 기준이 "패딩 존재"가 아니라 "변수 사용"이므로 자동 테스트는 별도 없음.
  - 시스템 폰트 스택은 CSS 파일 직접 확인으로 족함.

## 시각 검증

- 적용 여부: yes
- 대상 Screen IDs: home, search-filter-results, title-detail-top, title-detail-mid, title-detail-bottom
- visual_scope: approximate

### 카테고리별 결과

| Category | Expected | Observed | Result |
| --- | --- | --- | --- |
| coverage | 모든 주요 라우트(`/`, `/search`, `/titles/[id]`)에 `app-shell` 프레임 적용 + 데스크톱에서 중앙 배치 | Playwright `app-shell is constrained to a phone-width frame on every route` pass (iPhone 390px / desktop 430px 두 프로파일). `desktop viewport centers the app-shell with side margin` pass. 5개 screen 전부 커버. | pass |
| spacing | 44px 최소 터치 타겟(탭 아이템, Watch Now), `env(safe-area-inset-*)` 세이프 에어리어 반영 | Playwright `bottom tab items and Watch Now button have 44px+ touch targets` pass. `app/globals.css`의 `env(safe-area-inset-top/bottom)` 선언 확인. 시뮬레이션 한계로 정량 spacing은 approximate. | pass |
| hierarchy | sticky 상단 헤더 → scrollable main → sticky 하단(탭 바 / Watch Now 바). app-shell이 스크롤 컨테이너 | Rework 반영 후 `bottom tab bar is pinned to app-shell bottom on Home` + `Watch Now bar is pinned to app-shell bottom on detail` pass (bottom 차이 < 4px). `.app-shell` `height: 100dvh; overflow-y: auto` 적용 확인. | pass |
| tab bar | 상단 sticky 헤더와 하단 탭 바/Watch Now 바에 `backdrop-filter` 반투명 블러 적용 | Playwright `sticky header and bottom tab bar use backdrop-filter` pass (computed `backdrop-filter !== none`, iPhone/desktop 양쪽 프로파일). | pass |
| banner | 설문 베너 계약 유지(변경 없음). backdrop blur 대상 아님. | Home/Detail 회귀 스위트 계속 pass, `SurveyBanner` 단위 테스트 유지. 본 step에서 베너 관련 재정의 없음. | pass |
| typography | iOS 시스템 폰트 스택(`-apple-system`, `"SF Pro Text"`, `"SF Pro Display"`, `system-ui`)을 최상위 `font-family`로 선언 | `app/globals.css` 최상위 body 폰트 스택에서 직접 확인. 스크린샷에서 iOS 스타일 렌더 관찰. 자동 computed-style 검증은 없음 → approximate. | pass |

### 증거

- `docs/verification/evidence/step-07/home-iphone-13-portrait.png`
- `docs/verification/evidence/step-07/detail-iphone-13-portrait.png`
- `docs/verification/evidence/step-07/home-desktop-1280.png`
- `docs/verification/evidence/step-07/detail-desktop-1280.png`
- `docs/verification/evidence/step-07/desktop-centered.png`

## 문서 점검

- Updated Files:
  - `experiments/moyza-discovery/app/layout.tsx` (viewport 객체 `viewportFit: "cover"`, `interactiveWidget: "resizes-content"`, zoom 잠금)
  - `experiments/moyza-discovery/app/globals.css` (앱 shell max-width 프레임, 세이프 에어리어, 시스템 폰트, backdrop-filter 블러, 44px 터치 타겟, 데스크톱 프레임 배경/라운드/섀도)
  - `experiments/moyza-discovery/playwright.config.ts` (`desktop-1280` 프로젝트 추가, `app-feel.spec.ts` 전용 매칭)
  - `experiments/moyza-discovery/tests/e2e/app-feel.spec.ts` (신규)
  - `docs/architecture/technical-approach.md` (Decision 5 추가, Option C 확정)
  - `docs/plans/master-plan.md` (마일스톤 7 추가)
  - `docs/plans/steps/step-07.md` (신규)
- Result: pass
- Notes: README·CLAUDE.md는 변경 없음 (기능/placeholder 정책 동일).

## 판정

- `pass`

## 건너뛴 점검 (선택)

- User-approved skip: `env(safe-area-inset-*)` 실제 iOS 기기 렌더링 확인
- Reason: Playwright WebKit은 세이프 에어리어 값을 0으로 시뮬레이션하므로 자동 검증 불가. CSS에서 `env()` 변수 선언만 확인.

## 후속 조치

- Next allowed action: step-07을 `completed`로 표시. 프로젝트 전체 다시 `done` 상태.

## Rework 노트 (2026-04-20 후속)

초판 검증 후 사용자 피드백 발생: "하단 클릭 버튼이 고정되어 있지 않다". 원인 — `position: sticky; bottom: 0`를 쓰되 app-shell이 스크롤 컨테이너가 아니라 `min-height: 100vh`만 갖고 있어서 body가 스크롤 컨테이너가 됐고, sticky bottom이 프레임 하단이 아니라 body 하단 기준으로 동작했음. 또 app-shell의 `padding-bottom: calc(tab-height + safe-bottom)`이 fixed 바 시절의 잔여 스타일로 남아 탭 바 아래 공백을 만들었음.

수정:

- `.app-shell`을 스크롤 컨테이너로 전환: `height: 100dvh`, `overflow-y: auto`, `overflow-x: hidden`.
- 데스크톱 미디어쿼리도 `height: calc(100vh - 64px)`로 맞추고 `overflow: hidden` 제거(부모 프레임 라운드는 border-radius만으로 유지).
- `.home-main`, `.detail-main`에 `flex: 1 0 auto`로 공간 차지 → `.bottom-tabs`/`.watch-now-bar`의 `margin-top: auto`가 정상 동작.
- `.bottom-tabs`, `.watch-now-bar`에 `flex-shrink: 0` 추가로 축소 방지.
- 불필요했던 `padding-bottom` 제거.

추가된 회귀 방지 테스트(`app-feel.spec.ts`):

- `bottom tab bar is pinned to app-shell bottom on Home` — bar bottom과 app-shell bottom 차이 < 4px.
- `Watch Now bar is pinned to app-shell bottom on detail` — 동일 기준.

재검증: Vitest 43/43, Playwright 23 pass + 1 의도 skip(iphone 프로파일의 데스크톱 전용 테스트). 스크린샷 재생성됨.

참고: 하단 탭에서 `Account`가 보이지 않는 것은 PDF p.2 지시 "Account 숨기기"에 따른 의도된 상태다 — 복원이 필요하면 별도 요청으로 step 추가.

