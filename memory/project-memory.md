# 프로젝트 메모리

> 카테고리 범례 (phase-04):
> - `user`: 사용자 역할·목표·지식
> - `feedback`: "이렇게 하라 / 이렇게 하지 말라" 같은 작업 방식 지침
> - `project`: 이 프로젝트 유형에 특화된 사실/결정
> - `reference`: 외부 자원 포인터
>
> 승격 트리거: 같은 결정이 trace에 3회 이상 나타나면 `project-retrospective`가 후보로 제안한다. 사용자 명시 요청은 즉시 승격.
> visual fidelity 선호는 별도 항목 `visual fidelity 기본 수준 [feedback]`으로 저장한다.

## 프로젝트 기본값 [project]

- 모바일 우선 반응형 웹 MVP는 `experiments/<project-name>/` 하위에 Next.js App Router + TypeScript로 세운다.
- 개발 서버 포트는 3333 고정(사용자가 3000을 별도 사용).
- Playwright E2E는 iPhone 13 세로 프로파일을 기본으로 둔다 — 이 프로파일은 WebKit이므로 `npx playwright install webkit`이 필요하다.

## 기술 규칙 [project]

- **정적 시드 데이터(작품·필터)는 TS 모듈**로 두고 검색/필터는 클라이언트 메모리 연산으로 처리한다(수백 건 규모 MVP 기준). 타입은 이후 API 전환에 호환되도록 설계한다.
- **큐레이션(Home 섹션 등)은 작품 레코드와 분리**해 별도 파일(`src/data/home-sections.ts`처럼 섹션 키 + ID 배열)에 둔다. 이후 레코드 플래그(`isPopularPick` 등)로 이행할 때 UI 쪽 계약을 건드리지 않아도 된다.
- **Next.js App Router의 client 컴포넌트에서 `useSearchParams`/`usePathname` 사용 시** `<Suspense>` 경계로 감싸야 한다. 경계 없이 쓰면 prerender bailout.
- **Vitest에서 Next.js 컴포넌트를 렌더할 때** `vitest.setup.ts`에서 `next/link`(→ 단순 `<a>`)와 `next/navigation`(useRouter/usePathname/useSearchParams stub)을 mock 처리한다.
- **설문/외부 URL 류 placeholder는 환경변수로 주입**하고 module-scope 상수를 폴백으로 둔다(예: `NEXT_PUBLIC_SURVEY_URL` → `DEFAULT_SURVEY_URL`). 미설정 상태에서도 앱이 깨지지 않아야 한다.
- **플랫폼 배지처럼 "일정에 따라 on/off" 될 UI 블록**은 ENV boolean 플래그(`NEXT_PUBLIC_SHOW_*`)로 제어하고 컴포넌트에서 null을 반환해 완전 비활성화한다.

## 반복 결정 [project]

- **"코리아 픽" 류 큐레이션**: 단기는 별도 리스트 파일(작품 ID 배열), 장기는 레코드 플래그로 전환 지향. 질문하면 대개 이 2단계 안이 나온다.
- **step 수용 기준**: Vitest + Playwright(모바일 뷰포트) 시나리오 1~3건 + 스크린샷 + `docs/verification/step-xx-verification.md` 링크 — 본 프로젝트에서 6/6 재작업 없이 통과.
- **문서화 범위**: 루트 `README.md` + 프로젝트 `CLAUDE.md`(placeholder 교체 지점 표 포함) + `docs/verification/`. Storybook 등은 MVP 과투자.

## 반복 차단 패턴 [feedback]

- Playwright 초기 실행에서 device 프로파일과 설치 브라우저가 어긋나면 즉시 실패한다(예: iPhone 프로파일 + chromium만 설치 → WebKit 미탑재). step-01에서 `test:e2e:install` 스크립트를 webkit으로 지정해 방지.
- 이미지·로고 자산이 수령 전이면 gradient placeholder로 렌더해 둔다. 테스트가 이미지 로드에 의존하지 않아야 evidence 수집이 안정적.
- **모바일 프레임 형태 앱 shell에서 하단 sticky 바**: app-shell을 `height: 100dvh; overflow-y: auto`로 실제 스크롤 컨테이너로 만들어야 `position: sticky; bottom: 0`가 프레임 하단에 고정된다. `min-height: 100vh`만 주면 body가 스크롤 컨테이너가 되어 sticky가 엉뚱하게 동작한다. 회귀 방지용으로 "bar bottom ≈ app-shell bottom" Playwright 검증을 같이 둔다.
