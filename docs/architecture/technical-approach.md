# 기술 접근 방식

## 목적

상세 implementation planning을 시작하기 전에 필요한 confirmed technical direction을 기록합니다.

## 계획 게이트

아래 decision이 숨겨진 technical assumption을 피하기에 충분할 때만 master plan을 생성할 수 있습니다.

## 결정 영역

### 결정 1 — Application / Runtime Framework

- Area: Application / Runtime Framework
- Requirement Impact: 화면 3개 + 하단 탭을 모바일 세로형 다크 테마로 렌더링. 설문/Watch Now 외부 링크 이동이 자연스러워야 하고, 자산/ENV 교체만으로 로고/URL 반영 가능해야 함.
- Option 1: Next.js (App Router) 모바일 반응형 웹, port 3333
- Option 2: React Native (Expo) 네이티브 iOS/Android 앱
- Option 3: Vite + React SPA (react-router)
- Recommended Option: Option 1
- User Input: confirm (사용자 승인, 2026-04-20)
- Status: `confirmed`
- Confirmation Basis: 사용자 명시 승인 + harness memory의 "Next.js 3333 포트" 컨벤션 + MVP 범위가 웹 친화적(외부 링크, 정적 시드 가능, 로그인/푸시 없음).
- Decision Origin: `requirements` (요구사항의 "모바일 반응형 웹" 가정을 승인으로 확정)
- Risks: 실제 네이티브 제스처/햅틱 재현 불가 — 요구사항 success criteria는 영향받지 않음.
- Follow-up Needed: iOS Safari 다크 모드 렌더링은 step 단위에서 수동 확인.

### 결정 2 — Data Storage & Source of Truth

- Area: Data Storage
- Requirement Impact: 작품·필터 옵션·작품별 외부 URL을 제공해야 하며 MVP 기준 쓰기 없음. 설문/Watch Now placeholder 값을 한 곳에 모아 운영 교체 지점을 단순화해야 함.
- Option 1: TypeScript 정적 시드 모듈 (`src/data/*.ts`)
- Option 2: `public/` JSON + 클라이언트 fetch
- Option 3: SQLite + Next.js route handlers
- Recommended Option: Option 1
- User Input: confirm (사용자 승인, 2026-04-20)
- Status: `confirmed`
- Confirmation Basis: 사용자 명시 승인 + 요구사항 "최초 MVP에서 정적 시드 데이터" 조항 + 수백 건 규모 내 클라이언트 필터링 가능.
- Decision Origin: `requirements`
- Risks: 데이터 증가 시 API 전환 비용 — 타입을 API 호환 형태로 설계해 완화.
- Follow-up Needed: 설문 URL·Watch Now URL은 초기에는 시드 모듈 + 환경변수(Next.js `NEXT_PUBLIC_*`) 중 하나로 주입. 정확한 주입 방식은 step 단계에서 결정.

### 결정 3 — Testing Strategy

- Area: Testing Strategy
- Requirement Impact: step-gated execution + evidence-before-completion 규칙을 만족시키기 위해 각 step의 관찰 가능한 수용 기준을 검증 가능한 형태로 확보해야 함.
- Option 1: Vitest(unit/component) + Playwright(E2E + 스크린샷)
- Option 2: Vitest만 (unit + component)
- Option 3: Playwright만 (E2E 중심)
- Recommended Option: Option 1
- User Input: confirm (사용자 승인, 2026-04-20)
- Status: `confirmed`
- Confirmation Basis: 사용자 명시 승인. 필터·정렬 등 로직 검증은 Vitest, 레이아웃·흐름·외부 링크 이동 등 시각·통합 검증은 Playwright. step-verification에 Playwright 스크린샷을 근거로 첨부.
- Decision Origin: `ai-raised-approved-by-user`
- Risks: 초기 설정 공수 2배, Playwright 브라우저 바이너리 용량.
- Follow-up Needed: Playwright projectConfig에서 iPhone 13/14 세로 프로파일 사용, 스크린샷 저장 경로 규약은 step-docs에서 확정.

### 결정 5 — 앱 모사(App-feel) Visual Direction

- Area: UI/UX feel (웹 vs 앱 느낌)
- Requirement Impact: PDF가 iPhone 디바이스 프레임 + iOS 시스템 상태바 + 홈 인디케이터 + 네이티브 탭 바 구조를 포함한 **iOS 네이티브 앱 목업**이다. 초기 결정 1에서 Option 1(Next.js 웹)을 채택했을 때 이 시각적 계약을 과소평가했음 — 결과물이 데스크톱 뷰포트에서 "웹스럽다"는 피드백 발생.
- Option A: React Native (Expo)로 재스택 — 기존 투자 대부분 폐기
- Option B: PWA로 강화 (manifest + service worker + display standalone)
- Option C: **앱 모사 웹** — max-width 430px 프레임 중앙 정렬 + 세이프 에어리어 + iOS 시스템 폰트 + backdrop-filter 블러 + 터치 타겟 44px
- Recommended Option: Option C
- User Input: confirm (사용자 명시 승인, 2026-04-20)
- Status: `confirmed`
- Confirmation Basis: 기존 Next.js/TS/Vitest/Playwright/시드 투자를 최대한 재사용. 기능/라우트 변경 없이 CSS + layout meta만 보강. Option A는 재작업 비용이 높고, Option B의 PWA 설치 동작까지는 현 요구사항에 명시되지 않음.
- Decision Origin: `user-added-in-approach-selection` (초기 누락을 사후 정정)
- Risks:
  - iOS Safari에서만 체감되는 세이프 에어리어/상태바 겹침은 실제 기기에서 한 번 확인 필요.
  - 실제 네이티브 감각(햅틱, iOS 스크롤 바운스 정확도)은 재현 불가 — 수용 기준에서 제외.
- Follow-up Needed:
  - step-07에서 CSS 전환을 step-gated로 수행.
  - 이후 PWA/네이티브로 전환 여지를 열어두되, 현재는 웹 느낌만 최소화한다.

### 결정 4 — 파생 결정 (단일 viable)

아래 항목은 결정 1·2 또는 요구사항 out-of-scope에서 직접 도출되므로 개별 confirm 질문 없이 기록합니다.

- API / Integration Shape: 내부 API 없음. 외부 링크는 `Watch Now`의 작품별 `externalUrl`과 설문 URL 아웃바운드만. — Decision Origin: `derived from Decision 1+2`
- Authentication / Access: `not-needed`. 요구사항상 로그인/결제/프로필 전부 out-of-scope. — Decision Origin: `requirements`
- Deployment / Runtime Assumptions: MVP 단계에서는 로컬 `next dev -p 3333`만 보장. 호스팅(Vercel 등) 최종 결정은 project-transition/retrospective 단계로 연기. — Decision Origin: `derived from scope`

## 최종 방향

- Application / Runtime: Next.js (App Router) + TypeScript, 개발 서버 포트 3333, **앱 모사(App-feel) 모바일 웹**. max-width 430px 프레임 중앙 정렬, 세이프 에어리어 + iOS 시스템 폰트 + backdrop blur로 네이티브 느낌을 최대한 재현.
- Data Storage: TypeScript 정적 시드 모듈. 작품/필터/링크를 `src/data/`에 배치하고 검색·필터는 클라이언트 메모리 연산.
- API / Integration Shape: 내부 API 없음. `Watch Now`/설문 등은 외부 URL 아웃바운드만.
- Authentication / Access: `not-needed` (요구사항 out-of-scope).
- Testing Strategy: Vitest(unit/component) + Playwright(E2E + 모바일 뷰포트 스크린샷). step-verification 증거로 Playwright 결과물 활용.
- Deployment / Runtime Assumptions: MVP 단계 로컬 `next dev -p 3333`만 보장. 호스팅은 이후 단계로 연기.

## 메모

- 최종 방향 요약에는 confirmed decision만 기록합니다.
- 이후 결정이 추가될 때마다 해당 섹션을 갱신합니다.
