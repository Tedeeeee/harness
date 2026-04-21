# 개발 인터뷰 결정

## 목적

implementation plan을 작성하는 데 필요한 confirmed development decision을 기록합니다.

## 종료 조건

- 핵심 기술 선택이 결정되었다
- 테스트 기대치가 결정되었다
- 문서화 범위가 결정되었다
- unresolved item이 더 이상 implementation planning을 막지 않는다

## 결정 목록

### 결정 1 — "코리아 픽"/큐레이션 섹션 데이터 근거

- Topic: Home의 `업데이트된 신작` / `인기작 픽` / `코리아 픽` 섹션이 어떻게 채워지는가
- Current Decision: Option 3 + 향후 Option 2 지향
- Option 1: Country 필터 파생 (`country === "Korea"`)
- Option 2: 작품 레코드에 `isKoreaPick` / `isPopularPick` / `isNewRelease` 등 큐레이션 플래그 추가
- Option 3: `src/data/home-sections.ts`에 섹션별 작품 ID 배열을 별도 관리 (작품 레코드는 불변)
- User Input: "현 시점에서는 백엔드를 고려하지 않았으니까 3번으로 가고 나중에 2번을 지향하긴 해야해"
- Status: `confirmed`
- Confirmation Basis: 사용자 명시 지시(2026-04-20). 정적 시드 환경에서 책임 분리가 깔끔하고, 세 섹션(신작/인기작 픽/코리아 픽)이 동일한 패턴으로 구현되어 대칭성이 유지됨.
- Decision Origin: `user-added-in-interview`
- Follow-up Needed:
  - 향후 백엔드/CMS 도입 시 Option 2(작품 레코드 플래그)로 마이그레이션. 타입/데이터 접근 경로는 이를 염두에 두고 설계(예: `getSection(sectionKey)`가 내부 구현을 감추도록).
  - 섹션 키 네이밍과 각 섹션의 최대 노출 개수는 master-plan / step-docs에서 확정.

### 결정 2 — Step별 수용 기준(acceptance evidence) 수준

- Topic: 각 implementation step이 `verification-ready` → `complete`로 판정되기 위한 최소 evidence
- Current Decision: Option 2 (균형 기준)
- Option 1: 최소 기준 (Vitest 통과 + 화면 로드 스크린샷 1장)
- Option 2: 균형 기준 (Vitest 통과 + Playwright 시나리오 1~3개 + 모바일 뷰포트 스크린샷 + verification 문서 링크)
- Option 3: 엄격 기준 (Option 2 + 변경 파일 커버리지 목표 + 접근성/다크 모드 회귀 스냅샷)
- User Input: "오케이 2번 가자"
- Status: `confirmed`
- Confirmation Basis: 사용자 명시 승인(2026-04-20). evidence-before-completion 규칙과 PDF 기반 시각 검증 요구를 자연스럽게 충족하고, MVP 범위 대비 과투자를 피함.
- Decision Origin: `ai-raised-approved-by-user`
- Follow-up Needed:
  - `docs/verification/step-xx-verification.md`에 들어갈 필수 항목 템플릿(시나리오 설명, 스크린샷 파일 경로, Vitest 요약)은 step-docs 생성 단계에서 확정.
  - Playwright 프로젝트 설정에서 iPhone 13/14 세로 프로파일을 기본값으로 잡고, 스크린샷 저장 디렉터리 규약을 정한다(예: `docs/verification/evidence/step-xx/*.png`).

### 결정 3 — 문서화 범위

- Topic: 프로젝트 내 문서가 어디까지 유지되어야 하는가
- Current Decision: Option 2 (표준)
- Option 1: 최소 (루트 `README.md`만)
- Option 2: 표준 (`README.md` + 프로젝트 `CLAUDE.md` + `docs/verification/` 증거 + `docs/interview/` 결정 기록 유지, 코드 주석은 WHY only)
- Option 3: 풍부 (Option 2 + 컴포넌트 JSDoc + ADR + Storybook 등)
- User Input: "2"
- Status: `confirmed`
- Confirmation Basis: 사용자 명시 승인(2026-04-20). 하네스의 docs-first 관례와 정합되고, MVP 범위에서 Storybook 등 시각 라이브러리는 과투자.
- Decision Origin: `ai-raised-approved-by-user`
- Follow-up Needed:
  - 프로젝트 `CLAUDE.md`에 반드시 포함할 항목(실행 방법·테스트 명령·설문 URL 주입 규약·시드 데이터 경로 등)은 master-plan의 첫 step 산출물로 확정.
  - verification 문서 템플릿은 step-docs에서 정한다.

## 남은 gap에 대한 판정

아래 항목은 planning-critical이 아니라고 판단되어 interview를 종료하고 master-plan 단계에서 흡수한다:

- 설문 URL 주입 방식: 요구사항 "URL은 환경변수로 관리" 조항으로 방향이 이미 고정. 세부 키 이름(`NEXT_PUBLIC_SURVEY_URL` 등)은 step-docs에서 결정.
- Watch Now URL 데이터 필드 규약: 작품 타입 정의 step에서 `externalUrl` 또는 `platformLinks[]` 중 선택. Step 내 결정.
- Platform 필터 실제 이름 5종: 현재 `A/B/C/D/E` placeholder 유지, 실제 이름은 데이터 시드 편집만으로 교체 가능.
- Seed 초기 작품 수: MVP에 필요한 화면 시나리오 커버용 12~20개 범위가 합리적. 정확한 값은 data-seed step에서 결정.
- 전달드릴 로고 자산: placeholder SVG(텍스트 로고)로 임시 구현, 자산 수령 시 `public/logo.svg` 교체만으로 반영.
