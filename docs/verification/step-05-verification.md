# 스텝 검증

## 메타데이터

- Step: step-05
- Title: title-detail-screen
- Verification Date: 2026-04-20
- Result: pass
- Verification Doc Filename: `step-05-verification.md`

## 승인 기준 체크리스트

| Item | Expected | Evidence | Result |
| --- | --- | --- | --- |
| 1 | `/titles/{id}` 라우트에서 히어로/탭/메타/설문/Cast/Similar/WatchNow 모두 렌더 | Playwright `renders hero, tabs, sections, and Watch Now bar` pass. Vitest 상세 컴포넌트 개별 렌더 테스트 모두 pass. | pass |
| 2 | 공유 아이콘과 하트 아이콘이 DOM에 존재하지 않음 | Vitest `HeroSection > ... no share icon` pass, `WatchNowBar > ... excludes heart icon` pass. Playwright `no share icon in top bar, no heart icon in bottom bar` pass. | pass |
| 3 | Watch Now `href`가 해당 작품의 `externalUrl`이고 `target="_blank"` | Vitest `WatchNowBar > uses externalUrl, target=_blank` pass. Playwright `Watch Now href points to externalUrl and opens in new tab` pass (값: `https://example.invalid/watch/t-08`). | pass |
| 4 | `NEXT_PUBLIC_SHOW_PLATFORM_BADGES` 기본값에서 플랫폼 배지 블록이 렌더되지 않고, `true`일 때만 렌더 | Vitest `PlatformBadges flag` 2건 pass. Playwright `platform badges hidden when flag is default` pass. | pass |
| 5 | 스크롤 상단/중간/하단 3장의 모바일 스크린샷이 증거 폴더에 저장 | `docs/verification/evidence/step-05/detail-top-scroll.png`, `detail-mid-scroll.png`, `detail-bottom-scroll.png` 모두 존재 (+ 초기 `detail-top.png`). | pass |

## 테스트

- Commands Run:
  - `npm run typecheck` → exit 0
  - `npm run test` → 4 files / 43 tests pass (2.19s). 로그: `docs/verification/evidence/step-05/vitest.log`.
  - `npx playwright test` (전체) → 15/15 pass (24.9s). 상세 전용 6/6 pass. 로그: `docs/verification/evidence/step-05/playwright.log`.
- Result: all pass
- Notes:
  - Playwright의 `toHaveAttribute("href", /.../)` 정규식 매칭으로 externalUrl 확인.
  - PlatformBadges는 module-scope에서 `isPlatformBadgesEnabled()`를 호출하지 않고 render 시점에 평가하도록 구성. 환경변수 변경 후 재import 테스트가 가능.

## 수동 검증

- Check Performed: Playwright 스크린샷 3장(`detail-top-scroll.png`, `detail-mid-scroll.png`, `detail-bottom-scroll.png`)을 PDF p.4, p.5, p.1 썸네일 5와 대조.
  - Top: 히어로 + Synopsis + 메타 칩(`19+ 2025 20 EP Action More`) + 설문 베너 + Watch Now 하단 바 + 공유 아이콘 부재.
  - Mid: Synopsis 확장 상태 + 메타 표 + `View Summary` 토글.
  - Bottom: Cast 리스트(이름만) + Similar 가로 스크롤 + 고정 Watch Now 바 유지.
- Result: pass
- Notes: 이미지/포스터는 자산 수령 전이라 linear-gradient placeholder. PDF 장르가 "Drama"인 반면 `t-08`의 genre는 `Action` — 시드 데이터 정책(PDF 내 작품 카드와 메타를 그대로 복제하지 않고 균형 있는 분포를 우선)에 따른 의도된 차이.

## 시각 검증

- 적용 여부: yes
- 대상 Screen IDs: title-detail-top, title-detail-mid, title-detail-bottom
- visual_scope: approximate

### 카테고리별 결과

| Category | Expected | Observed | Result |
| --- | --- | --- | --- |
| coverage | visual-source-analysis.md의 Title Detail 3개 스크롤 상태에 명시된 요소(히어로·아이콘바·탭·Synopsis·메타 칩·메타 표·설문 베너·Cast·Similar·Watch Now)가 모두 렌더 | Playwright `renders hero, tabs, sections, and Watch Now bar` pass. 스크린샷 `detail-top-scroll.png` / `detail-mid-scroll.png` / `detail-bottom-scroll.png`에서 요소 전부 확인. 공유/하트 아이콘 부재, 플랫폼 배지 블록 기본 숨김. | pass |
| spacing | 단일 라우트 + 스크롤 상태 유지. 고정 Watch Now 바와 스크롤 섹션 겹침 없음 | 3장 스크린샷에서 Watch Now 바가 하단 고정 상태로 유지. Synopsis/메타 표/Cast/Similar 경계에서 잘림 또는 겹침 관찰 없음. 정량 토큰 부재 → approximate. | pass |
| hierarchy | 상단 아이콘 바 → 히어로 → `Synopsis / Cast / Similar` 탭 → Synopsis 본문 + 메타 칩 → 메타 표 + `View Summary` → 설문 베너 → Cast → Similar 순 | detail-top/mid/bottom 스크린샷과 `DetailTabs` Vitest 렌더 테스트로 순서 확인. | pass |
| tab bar | 상단 아이콘 바에서 공유 아이콘 부재. 하단은 Watch Now 바(전체폭, 하트 아이콘 부재). Detail 라우트에서는 앱 하단 탭 대신 Watch Now 바가 노출. | Vitest `HeroSection no share icon` + `WatchNowBar excludes heart icon` pass. Playwright `no share icon in top bar, no heart icon in bottom bar` pass. | pass |
| banner | 설문 베너가 Detail 중간 구간에서 `NEXT_PUBLIC_SURVEY_URL`(부재 시 placeholder)과 `target="_blank"`로 렌더 | Vitest `SurveyBanner URL behavior` 2건 pass (step-03에서 정의한 공용 계약 재사용). 스크린샷에서 베너 가시. | pass |
| typography | 본 step에서는 기본 sans-serif 유지. iOS 시스템 폰트 스택은 step-07에서 app-feel visual pass로 도입 | 시각 계약상 본 step 범위 외 → 후속 step-07에서 적용 확인. | n/a |

### 증거

- `docs/verification/evidence/step-05/detail-top-scroll.png`
- `docs/verification/evidence/step-05/detail-mid-scroll.png`
- `docs/verification/evidence/step-05/detail-bottom-scroll.png`
- `docs/verification/evidence/step-05/detail-top.png` (초기 load 상태)

## 문서 점검

- Updated Files:
  - `experiments/moyza-discovery/app/titles/[id]/page.tsx` (신규 라우트)
  - `experiments/moyza-discovery/src/components/HeroSection.tsx`
  - `experiments/moyza-discovery/src/components/DetailTabs.tsx`
  - `experiments/moyza-discovery/src/components/SynopsisPanel.tsx`
  - `experiments/moyza-discovery/src/components/MetaTable.tsx`
  - `experiments/moyza-discovery/src/components/PlatformBadges.tsx`
  - `experiments/moyza-discovery/src/components/CastList.tsx`
  - `experiments/moyza-discovery/src/components/SimilarSection.tsx`
  - `experiments/moyza-discovery/src/components/WatchNowBar.tsx`
  - `experiments/moyza-discovery/app/globals.css` (detail 스타일 추가)
  - `experiments/moyza-discovery/tests/unit/detail.test.tsx`
  - `experiments/moyza-discovery/tests/e2e/detail.spec.ts`
  - `experiments/moyza-discovery/CLAUDE.md` (플랫폼 배지 플래그 설명 보강)
- Result: pass
- Notes: README는 별도 업데이트 불필요(placeholder 교체 체크리스트에 플랫폼 배지 이미 포함).

## 판정

- `pass`

## 건너뛴 점검 (선택)

- User-approved skip: 없음
- Reason: N/A

## 후속 조치

- Next allowed action: step-05를 `completed`로 표시하고 step-06(마감 wiring + E2E 회귀) 활성화.
