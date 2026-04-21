# Moyza Discovery

모바일 반응형 웹 기반의 스트리밍 작품 탐색 앱 (리스킨).
상위 harness(`C:\workspace\harness\`)의 docs-first 규율 아래 step-gated로 개발한다.

## 요구 버전

- Node.js 20+ (개발은 Node 24로 확인)
- npm 10+

## 셋업

```bash
cd experiments/moyza-discovery
npm install
npx playwright install webkit
```

## 실행

```bash
npm run dev
```

- 개발 서버 포트는 **3333**. 사용자가 3000번을 별도로 사용 중이므로 본 프로젝트는 3333 고정.
- 브라우저에서 http://localhost:3333 접속.

## 테스트

```bash
npm run test           # Vitest (unit + component)
npm run test:e2e       # Playwright (iPhone 13 세로 프로파일)
npm run typecheck      # tsc --noEmit
```

## Placeholder 교체 체크리스트

운영/디자인 자산 수령 시 아래 지점만 교체하면 코드 변경 없이 반영된다.
(실제 참조는 이후 step에서 도입)

- 로고 자산: `public/logo.*` (step-03에서 도입 예정)
- 설문 URL: 환경변수 `NEXT_PUBLIC_SURVEY_URL` (step-03)
- Platform 필터 라벨: `src/data/filters.ts` (step-02)
- 작품별 외부 플랫폼 링크: `src/data/titles.ts`의 `externalUrl` (step-02)
- 플랫폼 배지 블록 표시 여부: `NEXT_PUBLIC_SHOW_PLATFORM_BADGES` (step-05)

## 디렉터리

- `app/` — Next.js App Router 페이지
- `src/` — 도메인 모듈(데이터/컴포넌트, 이후 step에서 채움)
- `tests/unit/` — Vitest 테스트
- `tests/e2e/` — Playwright 시나리오
- 스크린샷 증거는 harness 쪽 `docs/verification/evidence/step-xx/`에 저장
