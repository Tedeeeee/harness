# 스텝 검증

## 메타데이터

- Step: step-06
- Title: finalize-wiring-and-regression
- Verification Date: 2026-04-20
- Result: pass
- Verification Doc Filename: `step-06-verification.md`

## 승인 기준 체크리스트

| Item | Expected | Evidence | Result |
| --- | --- | --- | --- |
| 1 | Playwright E2E 회귀 스위트가 iPhone 13 세로 프로파일에서 끝까지 통과 | `tests/e2e/regression.spec.ts`의 `Home → Search → Detail → Watch Now → Back → Board` 시나리오 pass (6.5s). 전체 Playwright 16/16 통과. 로그: `docs/verification/evidence/step-06/playwright.log`. | pass |
| 2 | `NEXT_PUBLIC_SURVEY_URL` 미설정 환경에서 앱 구동 후 Home/Detail 베너가 placeholder 값으로 렌더 | Playwright `webServer`가 `.env.local` 없이 `npm run dev`를 기동했고, Home 설문 베너·Detail 설문 베너·Board 탭 모두 placeholder URL (`https://example.invalid/survey`)로 렌더되어 테스트가 통과. Vitest `SurveyBanner URL behavior > falls back to placeholder URL` 단위 테스트로도 확인. | pass |
| 3 | `README.md`에 placeholder 교체 체크리스트 섹션 존재 | `experiments/moyza-discovery/README.md` L36 `## Placeholder 교체 체크리스트`에 로고/설문 URL/Platform 라벨/외부 링크/플랫폼 배지 5종 포함. | pass |
| 4 | `CLAUDE.md`에 교체 지점 5종 목록 존재 | `experiments/moyza-discovery/CLAUDE.md` L26 `## Placeholder 교체 지점` 표 + L54 `자산 수령 시 흐름` 섹션에 5종 완비. | pass |
| 5 | 전체 Vitest + Playwright 스위트 한 번에 통과 | Vitest 4 files / 43 tests pass (2.32s). Playwright 16 tests pass (28.6s). 로그: `vitest.log`, `playwright.log`. | pass |

## 테스트

- Commands Run:
  - `npm run typecheck` → exit 0
  - `npm run test` → 43/43 pass
  - `npx playwright test` → 16/16 pass
- Result: all pass
- Notes:
  - 회귀 스크립트는 외부 URL로 실제 이동하지 않고 `href`/`target` 속성만 검증해 테스트 안정성을 유지.
  - 전체 회귀 스크린샷 4장(Home/Search/Detail/Board 탭 하단)이 `docs/verification/evidence/step-06/`에 저장.

## 수동 검증

- Check Performed:
  - `.env.local` 부재 상태에서 dev 서버 기동 → 크래시 없이 placeholder로 동작.
  - Home 설문 베너, Detail 설문 베너, Board 탭이 모두 같은 placeholder URL 참조.
  - 회귀 시나리오에서 Watch Now 링크가 작품 `externalUrl`(예: `https://example.invalid/watch/t-08`)을 가리키고 `target=_blank`로 외부 이동 의도 표현.
- Result: pass
- Notes: 실제 설문 URL / 로고 자산 / 플랫폼 이름을 수령하면 `.env.local` 또는 `src/data/*.ts` 교체만으로 반영 가능.

## 시각 검증

- 적용 여부: not-applicable
- 대상 Screen IDs: (none)
- visual_scope: not-applicable

### 카테고리별 결과

| Category | Expected | Observed | Result |
| --- | --- | --- | --- |
| coverage | — | 본 step은 wiring/E2E 회귀 전용. 신규 화면 요소 없음. | n/a |
| spacing | — | 동일. | n/a |
| hierarchy | — | 동일. | n/a |
| tab bar | — | 동일. | n/a |
| banner | — | 동일(설문 베너 placeholder 폴백 동작 검증은 승인 기준 #2에서 처리). | n/a |
| typography | — | 동일. | n/a |

### 증거

- 시각 수용 기준 없음. 화면별 시각 검증은 step-03(Home) / step-04(Search+Filter) / step-05(Title Detail) / step-07(app-feel visual pass)에서 각각 처리.
- 회귀 E2E 스크린샷(참고용, 시각 계약 acceptance 아님):
  - `docs/verification/evidence/step-06/regression-home.png`
  - `docs/verification/evidence/step-06/regression-search.png`
  - `docs/verification/evidence/step-06/regression-detail.png`
  - `docs/verification/evidence/step-06/regression-board.png`

## 문서 점검

- Updated Files:
  - `experiments/moyza-discovery/tests/e2e/regression.spec.ts` (신규)
  - (README.md / CLAUDE.md: step-01·05에서 이미 완비, 이번 step에서 추가 업데이트 불필요)
- Result: pass
- Notes: .env.example은 step-01에서 키 2종 사전 선언 상태 유지.

## 판정

- `pass`

## 건너뛴 점검 (선택)

- User-approved skip: 없음
- Reason: N/A

## 후속 조치

- Next allowed action: step-06을 `completed`로 표시하고 프로젝트 완료 상태 전환. 필요 시 `project-retrospective` 실행.
