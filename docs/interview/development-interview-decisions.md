# Development Interview Decisions

## Purpose

Capture the confirmed development decisions required to write an implementation plan.

## Exit Criteria

- key tech choices are decided
- test expectations are decided
- documentation scope is decided
- unresolved items no longer block implementation planning

## Decisions

### Decision 1 — UI 스타일링

- Topic: UI 스타일링 방식
- Current Decision: Tailwind CSS
- Option 1: Tailwind CSS — 유틸리티 클래스 기반, 빠른 프로토타이핑
- Option 2: shadcn/ui + Tailwind — 컴포넌트 세트 포함
- Option 3: CSS Modules — Next.js 기본 지원
- User Input: 1
- Status: `confirmed`
- Confirmation Basis: user selected option 1
- Decision Origin: `ai-raised-approved-by-user`
- Follow-up Needed: none

### Decision 2 — DB 접근 방식

- Topic: SQLite 접근 방식
- Current Decision: better-sqlite3 (직접 SQL)
- Option 1: Prisma ORM — 타입 안전, 마이그레이션 관리
- Option 2: Drizzle ORM — 경량 타입세이프 ORM
- Option 3: better-sqlite3 직접 SQL — 최소 의존성, 단순
- User Input: auto-mode default (option 3 — 1인용 로컬 앱에 ORM은 과도)
- Status: `confirmed`
- Confirmation Basis: auto-mode reasonable default for single-user local app
- Decision Origin: `ai-raised-approved-by-user`
- Follow-up Needed: none

### Decision 3 — 테스트 기대치

- Topic: 테스트 범위
- Current Decision: API route 단위 테스트 (Vitest)
- Option 1: API route 단위 테스트만
- Option 2: API + 컴포넌트 테스트
- Option 3: E2E 포함 전체 테스트
- User Input: auto-mode default (option 1 — 1인용 앱에 적절한 최소 범위)
- Status: `confirmed`
- Confirmation Basis: auto-mode reasonable default
- Decision Origin: `ai-raised-approved-by-user`
- Follow-up Needed: none

### Decision 4 — 문서화 범위

- Topic: 문서화 수준
- Current Decision: README에 설치·실행 방법만 기록
- Option 1: README에 설치·실행 방법만
- Option 2: README + API 문서
- Option 3: README + API + 아키텍처 문서
- User Input: auto-mode default (option 1 — 로컬 전용 개인 앱)
- Status: `confirmed`
- Confirmation Basis: auto-mode reasonable default
- Decision Origin: `ai-raised-approved-by-user`
- Follow-up Needed: none

## Interview Status

All exit criteria satisfied. Ready for master plan generation.
