# 스텝 검증

## 메타데이터

- Step: step-03
- Title: home-screen
- Verification Date: 2026-04-20
- Result: pass
- Verification Doc Filename: `step-03-verification.md`

## 승인 기준 체크리스트

| Item | Expected | Evidence | Result |
| --- | --- | --- | --- |
| 1 | Home 페이지에서 3개 섹션이 지정된 순서(신작→인기작 픽→코리아 픽)로 렌더 | Vitest `HomePage > renders the three home sections in the required order` pass (`tests/unit/home.test.tsx`). Playwright `Home screen > renders three curated sections in order` pass + 스크린샷 `home-sections.png`. | pass |
| 2 | 설문 베너 링크 href가 `NEXT_PUBLIC_SURVEY_URL` 값과 일치하고 `target="_blank"` | Vitest `SurveyBanner URL behavior` 2건 pass(환경변수 없으면 placeholder, 있으면 실제 값). Playwright `survey banner opens externally with survey URL` pass — href는 http(s) URL, target=_blank 확인. | pass |
| 3 | 하단 탭 바가 Home/Event/Board 3개만 존재(Account 없음) | Vitest `BottomTabBar > contains exactly three tabs ...` pass, Account 텍스트 부재 확인. Playwright `bottom tab bar shows exactly Home/Event/Board without Account` pass, 스크린샷 `home-bottom-tabs.png`. | pass |
| 4 | Event 탭 클릭 시 `/search` 로 이동 | Vitest `BottomTabBar > Event tab links to /search` pass. Playwright `Event tab navigates to /search` pass (실제 클릭 후 URL 매칭). | pass |
| 5 | Home 모바일 뷰포트 스크린샷이 증거 폴더에 저장 | `docs/verification/evidence/step-03/home-sections.png`, `home-bottom-tabs.png` 생성 확인. | pass |

## 테스트

- Commands Run:
  - `npm run typecheck` → exit 0
  - `npm run test` → 2 files / 27 tests pass (2.05s)
    - 기존 data 접근자 19건 + 신규 home 테스트 8건
    - 로그: `docs/verification/evidence/step-03/vitest.log`
  - `npx playwright test` → 4/4 pass (12.7s), iphone-13-portrait
    - 로그: `docs/verification/evidence/step-03/playwright.log`
- Result: all pass
- Notes:
  - `next/link`와 `next/navigation`은 `vitest.setup.ts`에서 mock 처리 (Link는 `<a>`로, `useRouter`/`usePathname`은 stub). Playwright는 실제 Next.js dev 서버에 붙으므로 mock 영향 없음.
  - `NEXT_PUBLIC_SURVEY_URL` 미설정 상태에서 기본 placeholder(`https://example.invalid/survey`)로 동작.

## 수동 검증

- Check Performed: Playwright 스크린샷 2장(`home-sections.png`, `home-bottom-tabs.png`)을 PDF p.2와 대조. 섹션 순서·설문 베너 상단 위치·하단 탭 3개 구성이 PDF 변경 지시와 정합.
- Result: pass
- Notes:
  - 로고는 "전달드릴 로고" 수령 전이라 텍스트 "Moyza" placeholder 유지. PDF p.2에서 기존 `Moyza` 로고와 동일 위치·모양 유지.
  - 포스터 이미지는 실제 자산 전이라 gradient placeholder로 렌더.
  - 지구본 아이콘/검색바/섹션 가로 스크롤 모두 구현.

## 문서 점검

- Updated Files:
  - `experiments/moyza-discovery/app/page.tsx` (placeholder → 실제 Home)
  - `experiments/moyza-discovery/app/search/page.tsx` (/search 라우트 placeholder, Event 탭 이동 대상)
  - `experiments/moyza-discovery/app/globals.css` (모바일 다크 테마 레이아웃 확장)
  - `experiments/moyza-discovery/src/components/` (Logo, SurveyBanner, SearchBar, PosterCard, PosterSection, BottomTabBar)
  - `experiments/moyza-discovery/src/lib/env.ts` (설문 URL/플랫폼 배지 플래그 getter)
  - `experiments/moyza-discovery/vitest.setup.ts` (next/link, next/navigation mocks)
  - `experiments/moyza-discovery/tests/unit/home.test.tsx` (신규)
  - `experiments/moyza-discovery/tests/e2e/home.spec.ts` (step-01 smoke 대체)
  - `experiments/moyza-discovery/tests/unit/smoke.test.tsx`(삭제), `tests/e2e/smoke.spec.ts`(삭제)
- Result: pass
- Notes: `.env.example`는 step-01에서 이미 생성되어 있어 변경 없음. step 문서의 `outputs`가 `app/(components)/`로 적혀 있었으나 실제 구현은 `src/components/`로 배치함 — Next.js 관례상 route-외 컴포넌트는 `src/` 쪽이 더 명확. 기능/검증에는 영향 없음.

## 판정

- `pass`

## 건너뛴 점검 (선택)

- User-approved skip: 없음
- Reason: N/A

## 후속 조치

- Next allowed action: step-03를 `completed`로 표시하고 step-04 활성화(`/search` 실제 구현).
