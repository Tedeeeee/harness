# 기술 접근 방식

## 목적

KEYBODER 이커머스 웹사이트를 프로토타입 코드 번들에서 프로덕션 스택으로 재구현하기 위한 기술 결정.

## 계획 게이트

아래 6개 결정이 확정되어 master plan 생성 가능.

## 결정 영역

### 결정 1: 스타일링 전략

- Area: Styling
- Requirement Impact: 11개 화면의 디자인 토큰 이식, 다크/라이트 테마
- Option 1: Global CSS + CSS Modules
- Option 2: Global CSS 변수 + Tailwind CSS
- Option 3: Global CSS only (BEM)
- Recommended Option: Option 2
- User Input: Option 2 선택
- Status: confirmed
- Confirmation Basis: 사용자 직접 선택 2026-04-22
- Decision Origin: ai-raised-approved-by-user
- Risks: 프로토타입의 정밀 shadow/gradient를 Tailwind 커스텀으로 매핑하는 작업 필요
- Follow-up Needed: tailwind.config에서 CSS 변수 매핑 설계

### 결정 2: 클라이언트 상태 관리

- Area: State Management
- Requirement Impact: 장바구니/위시리스트/테마가 모든 라우트에서 공유
- Option 1: React Context (Provider 중첩)
- Option 2: Zustand (persist 미들웨어)
- Recommended Option: Option 2
- User Input: (자동 선택 — 추천안)
- Status: confirmed
- Confirmation Basis: 추천안 자동 확정 2026-04-22
- Decision Origin: ai-raised-approved-by-user
- Risks: 외부 의존성 1개 추가
- Follow-up Needed: 없음

### 결정 3: Playwright 테스트 프로파일

- Area: Testing Strategy
- Requirement Impact: E2E 테스트 환경, 스크린샷 기준
- Option 1: iPhone 13 세로 (WebKit) — 모바일 우선
- Option 2: Desktop Chromium 1280×720 + 모바일 보조
- Recommended Option: Option 2
- User Input: (자동 선택 — 추천안)
- Status: confirmed
- Confirmation Basis: 프로토타입이 데스크톱 우선(1440px 컨테이너, 768px 브레이크포인트), 모바일은 보조 프로파일로 커버
- Decision Origin: ai-raised-approved-by-user
- Risks: 모바일 레이아웃 회귀를 놓칠 수 있음 → 모바일 보조 프로파일 추가로 보완
- Follow-up Needed: playwright.config에 desktop(primary) + mobile(secondary) 프로젝트 구성

### 결정 4: 프로토타입 재사용 경계

- Area: Prototype Reuse Boundary
- Requirement Impact: 구현 속도 vs 코드 품질
- Option 1: 프로토타입 코드를 직접 리팩터링 (Babel→Next.js 마이그레이션)
- Option 2: 프로토타입은 참조만, Next.js/TS/Tailwind로 완전 새로 작성
- Option 3: 데이터/로직만 이식, UI는 새로 작성
- Recommended Option: Option 3
- User Input: (자동 선택 — 추천안)
- Status: confirmed
- Confirmation Basis: 프로토타입의 인라인 스타일 + UMD React 구조는 Next.js와 호환 불가. 데이터(제품/필터/가격)와 비즈니스 로직(장바구니 계산/필터링/정렬)은 타입 안전하게 이식 가능.
- Decision Origin: ai-raised-approved-by-user
- Risks: UI 재작성 시간 필요하지만, 프로토타입의 정확한 디자인 토큰이 있으므로 시각적 동등성 확보 가능
- Follow-up Needed: 없음

### 결정 5: 데이터 레이어

- Area: Data Storage and Schema
- Requirement Impact: 제품/키캡/스위치/액세서리/매거진 데이터
- Option 1: 정적 TS 시드 모듈 (src/data/)
- Option 2: JSON 파일 + API route
- Recommended Option: Option 1
- User Input: (자동 선택 — 추천안, memory 기본값과 일치)
- Status: confirmed
- Confirmation Basis: 프로토타입 하드코딩 데이터를 TS 타입 모듈로 이식. 향후 API 전환 호환 설계. memory 기본값.
- Decision Origin: requirements
- Risks: 없음
- Follow-up Needed: 없음

### 결정 6: 라우팅 구조

- Area: Application / Runtime
- Requirement Impact: 11개 화면의 URL 구조
- Option 1: Next.js App Router 파일 기반 라우팅
- Recommended Option: Option 1 (유일한 합리적 선택)
- User Input: (자동 선택 — 추천안)
- Status: confirmed
- Confirmation Basis: requirements에서 Next.js App Router 확정
- Decision Origin: requirements
- Risks: 없음
- Follow-up Needed: 없음

## 최종 방향

- Application / Runtime: Next.js 15 App Router + TypeScript, 포트 3333
- Data Storage: src/data/ TS 정적 시드 모듈, 접근자 함수, 향후 API 전환 호환 타입
- API / Integration Shape: 없음 (MVP 프론트엔드만)
- Authentication / Access: 없음 (프로필은 데모 데이터)
- Testing Strategy: Vitest(단위/컴포넌트) + Playwright(Desktop Chromium 1280x720 primary, Mobile 375px secondary)
- Deployment / Runtime Assumptions: 로컬 dev 환경만 (next dev -p 3333)
- Prototype Reuse Boundary: 데이터 구조 + 비즈니스 로직(필터/정렬/계산)을 TS로 이식
- Prototype Rewrite Boundary: UI 전체(인라인 스타일 → Tailwind), 런타임(Babel standalone → Next.js 빌드), 상태 관리(App.jsx useState → Zustand 스토어), 라우팅(page state → App Router 파일 라우트)

## 메모

- 프로토타입의 CSS 변수(colors, shadows, fonts)는 globals.css에서 그대로 사용하고 Tailwind 테마에서 참조
- 프로토타입의 제품 데이터(PRODUCTS, CATALOG, KEYCAPS, SWITCHES, ACCESSORIES, ARTICLES)는 TS 타입과 함께 src/data/로 이식
- 프로토타입의 비즈니스 로직(필터 AND 논리, 정렬 comparator, 장바구니 계산, 프로모 코드)은 순수 함수로 이식
- TweakPanel, 편집 모드, postMessage, alert 결제는 버림
