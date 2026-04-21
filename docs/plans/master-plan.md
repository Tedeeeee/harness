# 마스터 플랜

## 목표

Moyza 프로토타입을 기반으로 한 **모바일 반응형 웹 작품 탐색 앱**(리스킨)을 로컬 `next dev -p 3333` 환경에서 end-to-end로 시연 가능한 상태까지 구현한다. Home / Search+Filter / Title Detail 3개 화면과 Home/Event/Board 하단 탭 내비게이션이 요구사항의 수용 기준을 만족해야 한다.

## 방향

- Application: Next.js 15 App Router + TypeScript. 개발 서버 포트 3333. 다크 테마 기본, 모바일 뷰포트(iPhone 세로) 우선 레이아웃.
- Data: 모든 작품/섹션/필터 옵션을 `src/data/`의 TypeScript 시드 모듈로 제공. 검색·필터는 클라이언트 메모리 연산. 쓰기 없음.
- Curation: 작품 레코드는 콘텐츠 속성만 담고, Home의 `업데이트된 신작 / 인기작 픽 / 코리아 픽`은 `src/data/home-sections.ts`의 작품 ID 배열로 구성한다. 이 구조는 추후 레코드 플래그로 이행 가능한 형태로 감싼다.
- External wiring: 설문 URL은 `NEXT_PUBLIC_SURVEY_URL` 환경변수로 주입(값 부재 시 placeholder). Watch Now는 작품 타입의 `externalUrl`. 플랫폼 배지 블록은 MVP에서 기본 숨김.
- Placeholder: 로고는 임시 텍스트/SVG. Platform 필터 옵션은 `A/B/C/D/E` placeholder 라벨 유지.
- Testing: Vitest로 로직/컴포넌트 단위 검증, Playwright(iPhone 세로 프로파일)로 주요 흐름 E2E + 모바일 스크린샷.
- Docs: 프로젝트 루트 `README.md` + `CLAUDE.md` 유지, `docs/verification/step-xx-verification.md`에 step별 증거 첨부.

## 포함 범위

- Home 화면: 로고 슬롯, 지구본 토글(UI만), 키워드 검색바, **상단 고정 설문 베너**, 섹션 3개(`업데이트된 신작` → `인기작 픽` → `코리아 픽`, 각 가로 스크롤 포스터 카드).
- 하단 탭 내비게이션: `Home` / `Event`(탐색 아이콘, Search+Filter 라우트로 이동) / `Board`(설문 링크 아웃바운드). Account 없음.
- Search + Filter 화면: 뒤로가기 + 키워드 입력, Filter 섹션(Country/Genre/Platform, Platform은 텍스트-only 칩), `Results N` + `Latest first` 정렬, 포스터 그리드 결과.
- Title Detail 화면(단일 페이지 + 스크롤 상태): 히어로 + 타이틀 + 별점, 상단 아이콘 바(뒤로가기/검색, 공유 숨김), 탭(`Synopsis / Cast / Similar`), Synopsis 본문 + 메타 칩, 메타 정보 표 + `View Summary`, 설문 베너, Cast(이름만), 하단 고정 `Watch Now` 전체폭(하트 숨김), 플랫폼 배지 블록은 기본 숨김 + 플래그로 on/off 가능.
- 데이터 시드: 최소 12~20개 작품, 국가/장르/플랫폼 필터 조합이 의미 있도록 분포.
- 테스트: 위 수용 기준별 Vitest 유닛 + Playwright 시나리오 + 모바일 뷰포트 스크린샷.
- 문서: `README.md`(셋업/실행/테스트), `CLAUDE.md`(규약·주의), `docs/verification/step-xx-verification.md`(증거 링크).

## 비목표

- Account / 로그인 / 결제 / 구독 관리 UI.
- 홈의 `Trends` 및 확정된 3개 섹션 외 영역.
- 작품 상세 공유 기능, 하트(찜) 기능, 리뷰 작성/편집, 댓글.
- 앱 내 설문 입력 UI — 설문은 외부 링크 리다이렉트만.
- 푸시 알림, CMS, 이미지 자산 업로드 파이프라인.
- 백엔드 API, DB, 인증.
- 호스팅(Vercel 등) 배포 구성 — MVP는 로컬 dev만.
- Platform 5종 실제 이름 확정, 전달드릴 로고 자산 교체(수령 시 placeholder swap만 하면 되는 구조만 만든다).
- 국제화 실제 로케일 데이터 (지구본 토글 UI는 유지, 내부 문자열은 한국어 단일).
- 접근성 회귀 스냅샷, 라인 커버리지 수치 목표(합의된 수용 기준에 없음).

## 개발 규칙

- **기술 선택**: Next.js App Router + TS(port 3333), TS 정적 시드, Vitest + Playwright. API/Auth/배포는 이번 범위 밖.
- **테스트 완료 규칙**: 각 step은 ① 해당 step이 추가/변경한 로직에 대한 Vitest 통과, ② Playwright 시나리오 1~3개(주요 행동 경로 + 관련 엣지 1개 이상) 통과, ③ iPhone 세로 뷰포트 모바일 스크린샷 1장 이상, ④ `docs/verification/step-xx-verification.md`에서 위 증거 파일 경로를 링크할 것.
- **문서화 완료 규칙**: 각 step은 ① 이 step이 바꾼 공개 규약(설정 키, 시드 경로, 환경변수 등)을 `README.md` 또는 `CLAUDE.md`에 반영, ② 해당 step verification 문서 작성. 코드 주석은 WHY에 한정.
- **Scope 고정**: 새로운 화면/기능은 master-plan에서 허용한 범위 안에서만. 범위 확장이 필요하면 implementation을 멈추고 planner로 돌아간다.

## 마일스톤

1. **프로젝트 스캐폴드** — `next create`로 App Router + TS 앱을 프로젝트 하위 폴더(예: `app/`)에 세운다. 다크 테마 기본값 설정, 포트 3333 스크립트, Vitest + React Testing Library, Playwright(iPhone 13 세로 프로파일) 구성. 루트 `README.md`와 프로젝트 `CLAUDE.md` 초안. 빈 첫 페이지 한 장의 Playwright 스크린샷이 나와야 완료.
2. **데이터 모델과 시드** — `src/data/`에 `Title` / `FilterOptions` / `HomeSection` 타입 정의, 작품 12~20개 시드, 필터 옵션(Country·Genre·Platform `A/B/C/D/E`), `home-sections.ts`의 3개 섹션 ID 배열, `externalUrl` placeholder 값. 접근자 함수(`getSection`, `searchTitles`, `filterTitles`) + Vitest 유닛.
3. **Home 화면** — 로고 placeholder, 키워드 검색바(동작: Search 페이지로 네비게이션 or 검색어 querystring), 최상단 설문 베너(ENV 링크), 3개 섹션 가로 스크롤 렌더, 하단 탭 바(Home/Event/Board, Account 없음). Playwright에서 3개 섹션 순서와 하단 탭 구성 확인.
4. **Search + Filter 화면** — 라우트(`/search`), 뒤로가기/검색 헤더, Filter 섹션(Country/Genre/Platform 칩 — Platform은 텍스트-only), `Results N` 카운트와 `Latest first` 정렬, 결과 포스터 그리드. Event 탭이 이 라우트로 이동. 필터 조합·정렬 Vitest + Playwright 시나리오.
5. **Title Detail 화면** — 라우트(`/titles/[id]`), 히어로/타이틀/별점, 상단 아이콘 바(뒤로/검색, 공유 숨김), 탭(Synopsis/Cast/Similar), 메타 칩·표·`View Summary`, 설문 베너(ENV), Cast 이름-only, 하단 고정 `Watch Now`(전체폭·`externalUrl`로 이동·`target="_blank"`), 하트 숨김. 플랫폼 배지 블록은 환경 플래그/시드 값 기반 on/off. Playwright에서 Watch Now 외부 이동 가로채기 확인.
6. **마감 및 wiring** — `NEXT_PUBLIC_SURVEY_URL` 결여 시 동작, 로고 placeholder swap 지점 문서화, 플랫폼 배지 숨김 플래그 기본값 확인, 누락된 텍스트(접근성·에러 경로) 보강, E2E 회귀 Playwright 스위트 1회, `README.md` / `CLAUDE.md` 최종 정리.
7. **앱 모사 visual pass** — Decision 5 (2026-04-20 추가) 반영. 앱 shell max-width 430px 중앙 정렬, 세이프 에어리어 처리, iOS 시스템 폰트, 상단 헤더·하단 탭·Watch Now 바에 backdrop blur, 터치 타겟 44px 최소, `viewport-fit=cover`, 데스크톱 뷰포트에서 프레임 중앙 렌더. 기능 변경 없음, CSS + layout meta만.

## 위험

- **시각 해석 오차**: PDF가 유일한 시각 원천이고 디자인 토큰(색·간격·폰트 크기)이 정량값으로 없음 → step별 Playwright 스크린샷을 PDF 이미지와 나란히 비교해 편차를 기록하고 허용 수준을 결정.
- **데이터 현실성 부족**: 시드 12~20개가 필터 조합을 충분히 커버하지 못하면 검색/필터 수용 기준이 약화됨 → 데이터 시드 step에서 국가/장르/플랫폼 분포를 의도적으로 균형 있게 구성.
- **외부 이동 테스트 취약성**: Watch Now의 외부 링크 이동을 Playwright로 안정적으로 검증하기 어려움 → `target="_blank"` + `href` 검증과 window.open 모킹을 병행, 실제 네비게이션은 smoke 1회만.
- **Placeholder 누출**: `A/B/C/D/E` 플랫폼 라벨, 임시 로고, `NEXT_PUBLIC_SURVEY_URL` 미설정 값이 자산 수령 후 교체에서 빠지면 운영 문제 → 교체 지점 목록을 `CLAUDE.md`에 명시하고 마지막 step에서 체크리스트로 확인.
- **스크롤 상태 UX**: Title Detail을 단일 페이지 + 스크롤 상태로 구현할 때 고정 하단 바와 스크롤 탭(Synopsis/Cast/Similar) 위치 충돌 가능 → step 5에서 iOS Safari 시뮬레이션으로 겹침을 직접 확인.

## 완료 정의

- 로컬 `next dev -p 3333`에서 Home → Search+Filter → Title Detail → Watch Now(외부 링크) → 뒤로가기 → Board(설문 링크)의 흐름이 모두 동작한다.
- 요구사항(`docs/requirements/moyza-discovery-app.md`)의 Success Criteria 8개 항목이 Playwright 시나리오와 수동 관찰로 모두 통과된다.
- Vitest 스위트가 전체 통과한다.
- 각 step의 `docs/verification/step-xx-verification.md`에 증거 파일 경로가 링크되어 있다.
- `README.md`와 프로젝트 `CLAUDE.md`에 셋업/실행/테스트/placeholder 교체 지점이 정리되어 있다.
- 전달드릴 로고 자산과 실제 설문 URL을 수령했을 때 코드 변경 없이 자산 파일 교체 + 환경변수 설정만으로 운영 반영이 가능하다.
