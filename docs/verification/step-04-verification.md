# 스텝 검증

## 메타데이터

- Step: step-04
- Title: search-filter-screen
- Verification Date: 2026-04-20
- Result: pass
- Verification Doc Filename: `step-04-verification.md`

## 승인 기준 체크리스트

| Item | Expected | Evidence | Result |
| --- | --- | --- | --- |
| 1 | Event 탭에서 `/search`로 이동하고 초기 결과 목록이 렌더 | Playwright `Event tab lands on /search with default results` pass. 결과 카운트 > 0. 스크린샷 `search-initial.png`. | pass |
| 2 | Country+Genre+Platform 각 칩을 토글하면 `Results N`이 정확한 값으로 갱신 | Vitest `narrows results with combined ... selections` pass + `allows multiple chips within a single category (OR within, AND across)` pass + `renders zero results when no title matches the combo` pass. Playwright `toggling country + genre + platform narrows results` pass, 스크린샷 `search-narrowed.png`. | pass |
| 3 | Platform 칩이 배경·아이콘 없이 텍스트-only 스타일로 렌더 | Vitest `uses text-only chip variant` pass (클래스 `chip--text`, `chip--pill` 아님). Playwright `platform chips render as text-only` pass. | pass |
| 4 | 결과 카드 href가 `/titles/{id}`를 가리킴 | Vitest `link to /titles/{id}` pass. Playwright `result cards link to /titles/{id}` pass. | pass |
| 5 | 모바일 뷰포트 Playwright 스크린샷 저장 | `docs/verification/evidence/step-04/search-initial.png`, `search-narrowed.png` 생성 확인. | pass |

## 테스트

- Commands Run:
  - `npm run typecheck` → exit 0
  - `npm run test` → 3 files / 33 tests pass (1.95s). 로그: `docs/verification/evidence/step-04/vitest.log`
  - `npx playwright test` → 9/9 pass (16.8s), iphone-13-portrait. 로그: `docs/verification/evidence/step-04/playwright.log`
- Result: all pass
- Notes:
  - `filterTitles` 시그니처를 `country?: Country | readonly Country[]` 형태로 확장해 단일/다중 선택을 모두 지원. 기존 step-02 단위 테스트(단일 선택)는 변경 없이 통과.
  - `useSearchParams` 사용을 위해 `/search` 페이지를 `Suspense`로 감쌈.
  - `?q=` 초기 키워드도 Playwright에서 검증 (레이디 → 결과 존재).

## 수동 검증

- Check Performed: Playwright 스크린샷 2장을 PDF p.3와 대조. Filter 섹션 구성(Country/Genre/Platform), Platform이 텍스트-only 스타일, `Results N` + `Latest first` 드롭다운 배치 확인.
- Result: pass
- Notes: 포스터 이미지는 gradient placeholder. 결과 카드가 3열 그리드로 렌더.

## 문서 점검

- Updated Files:
  - `experiments/moyza-discovery/src/data/types.ts` (FilterSelection 시그니처 확장)
  - `experiments/moyza-discovery/src/data/accessors.ts` (`matchesEither` 헬퍼)
  - `experiments/moyza-discovery/src/components/FilterHeader.tsx` (신규)
  - `experiments/moyza-discovery/src/components/FilterBar.tsx` (신규, 멀티셀렉트)
  - `experiments/moyza-discovery/src/components/SortDropdown.tsx` (신규)
  - `experiments/moyza-discovery/src/components/ResultsGrid.tsx` (신규)
  - `experiments/moyza-discovery/app/search/page.tsx` (placeholder → Suspense 감싼 실제 화면)
  - `experiments/moyza-discovery/app/globals.css` (search/filter 스타일 추가)
  - `experiments/moyza-discovery/tests/unit/search.test.tsx` (신규)
  - `experiments/moyza-discovery/tests/e2e/search.spec.ts` (신규)
- Result: pass
- Notes: README/CLAUDE.md는 step-04에서 변경할 필요 없음.

## 판정

- `pass`

## 건너뛴 점검 (선택)

- User-approved skip: 없음
- Reason: N/A

## 후속 조치

- Next allowed action: step-04를 `completed`로 표시하고 step-05(작품 상세) 활성화.
