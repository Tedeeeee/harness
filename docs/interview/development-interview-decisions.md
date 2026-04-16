# 개발 인터뷰 결정

## 목적

implementation plan을 작성하는 데 필요한 confirmed development decision을 기록한다.

## 종료 조건

- 핵심 기술 선택이 결정되었다
- 테스트 기대치가 결정되었다
- 문서화 범위가 결정되었다
- unresolved item이 더 이상 implementation planning을 막지 않는다

## 결정 목록

### 결정 1 — UI 스타일링

- Topic: UI 스타일링 방식
- Current Decision: Tailwind CSS
- Option 1: Tailwind CSS — 유틸리티 클래스 기반, 빠른 프로토타이핑
- Option 2: shadcn/ui + Tailwind — 컴포넌트 세트 포함
- Option 3: CSS Modules — Next.js 기본 지원
- User Input: 1
- Status: `confirmed`
- Confirmation Basis: 사용자가 1번 옵션을 선택함
- Decision Origin: `ai-raised-approved-by-user`
- Follow-up Needed: 없음

### 결정 2 — DB 접근 방식

- Topic: SQLite 접근 방식
- Current Decision: better-sqlite3 (직접 SQL)
- Option 1: Prisma ORM — 타입 안전, 마이그레이션 관리
- Option 2: Drizzle ORM — 경량 타입세이프 ORM
- Option 3: better-sqlite3 직접 SQL — 최소 의존성, 단순
- User Input: auto-mode default (option 3 — 1인용 로컬 앱에 ORM은 과도)
- Status: `confirmed`
- Confirmation Basis: 1인용 로컬 앱에 대한 auto-mode의 합리적인 기본값
- Decision Origin: `ai-raised-approved-by-user`
- Follow-up Needed: 없음

### 결정 3 — 테스트 기대치

- Topic: 테스트 범위
- Current Decision: API route 단위 테스트 (Vitest)
- Option 1: API route 단위 테스트만
- Option 2: API + 컴포넌트 테스트
- Option 3: E2E 포함 전체 테스트
- User Input: auto-mode default (option 1 — 1인용 앱에 적절한 최소 범위)
- Status: `confirmed`
- Confirmation Basis: auto-mode의 합리적인 기본값
- Decision Origin: `ai-raised-approved-by-user`
- Follow-up Needed: 없음

### 결정 4 — 문서화 범위

- Topic: 문서화 수준
- Current Decision: README에 설치·실행 방법만 기록
- Option 1: README에 설치·실행 방법만
- Option 2: README + API 문서
- Option 3: README + API + 아키텍처 문서
- User Input: auto-mode default (option 1 — 로컬 전용 개인 앱)
- Status: `confirmed`
- Confirmation Basis: auto-mode의 합리적인 기본값
- Decision Origin: `ai-raised-approved-by-user`
- Follow-up Needed: 없음

## 인터뷰 상태

모든 종료 조건이 충족되었다. master plan 생성 준비 완료.
