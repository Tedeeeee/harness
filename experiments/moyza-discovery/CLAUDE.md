# Moyza Discovery — 프로젝트 규약

harness(`C:\workspace\harness\`) 아래에 있는 step-gated 실행 프로젝트다.
새 작업을 시작하기 전에 항상 아래를 읽는다.

## 절대 규칙

- **포트 3333 고정**. 사용자가 3000을 별도 프로세스에 사용 중이다.
- step-gated. `docs/implementation/implementation-state.md`가 가리키는 active step의 in-scope만 구현한다. 다음 step 작업을 미리 하지 않는다.
- evidence-before-completion. 검증 증거는 harness의 `docs/verification/` 쪽에 저장한다.

## 디렉터리 규약

- `app/` — Next.js App Router 라우트 (현재 루트 placeholder만 존재)
- `src/data/` — 정적 시드 데이터와 접근자
  - `types.ts` — `Title`, `Country`, `Genre`, `Platform`, `HomeSection` 등
  - `titles.ts` — 작품 시드 15개 (Korea/USA/China/Japan 분포, Platform A–E)
  - `filters.ts` — `COUNTRIES`, `GENRES`, `PLATFORMS`, `FILTER_OPTIONS`
  - `home-sections.ts` — `HOME_SECTIONS` (`new-releases` / `popular-picks` / `korea-picks`), `HOME_SECTION_MAX_ITEMS`
  - `accessors.ts` — `getTitleById`, `getAllTitles`, `getSection`, `getAllSections`, `filterTitles`, `searchTitles`
  - `index.ts` — 배럴 export
- `src/components/` 또는 `app/(components)/` — 재사용 컴포넌트
- `tests/unit/` — Vitest 단위/컴포넌트 테스트
- `tests/e2e/` — Playwright 시나리오 (iPhone 13 세로 프로파일)

## Placeholder 교체 지점

아래 값은 사용자 자산 수령 시 코드 변경 없이 교체 가능해야 한다.
실제 와이어링은 각 괄호 안의 step에서 도입.

| 지점 | 경로 / 키 | 도입 step |
| --- | --- | --- |
| 전달드릴 로고 | `public/logo.*` | step-03 |
| 설문 URL | ENV `NEXT_PUBLIC_SURVEY_URL` | step-03 |
| Platform 필터 라벨 | `src/data/filters.ts` | step-02 |
| 작품별 외부 링크 | `src/data/titles.ts` `externalUrl` | step-02 |
| 플랫폼 배지 표시 플래그 | ENV `NEXT_PUBLIC_SHOW_PLATFORM_BADGES` (기본 `false`; `true`일 때 상세 Synopsis 아래에 NETFLIX / TVING / coupang play 렌더) | step-05 |

## 코드 스타일

- TypeScript strict 유지.
- 주석은 WHY에만. 식별자가 설명하는 것을 중복 기술하지 않는다.
- 과도한 추상화/백워드 호환 레이어 금지. 현재 step이 필요로 하는 만큼만.
- 에러 핸들링은 외부 경계에서만(여기서는 외부 링크 이동, ENV 부재 정도).

## 테스트 규약

- Vitest: 해당 step이 추가/변경한 로직에 붙인다.
- Playwright: 요구사항의 관찰 가능한 수용 기준을 시나리오로 변환. iPhone 13 세로 프로파일 사용. 스크린샷은 `docs/verification/evidence/step-xx/` 경로로 저장.

## 자산 수령 시 흐름

1. 로고 자산 수령 → `public/`에 파일 교체
2. 설문 URL 수령 → `.env.local`에 `NEXT_PUBLIC_SURVEY_URL` 설정
3. Platform 5종 실제 이름 수령 → `src/data/filters.ts` Platform 배열 업데이트
4. Watch Now 실제 URL → `src/data/titles.ts`의 `externalUrl` 업데이트 (또는 API 도입)
