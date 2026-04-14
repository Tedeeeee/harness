---
id: step-01
title: 프로젝트 초기화 및 DB 스키마
status: draft
depends_on: []
outputs: [Next.js 프로젝트, SQLite DB 파일, reviews 테이블]
acceptance: [npm run dev 실행 가능, DB 파일 생성됨, 테이블 스키마 확인 가능]
---

# Step 01 — 프로젝트 초기화 및 DB 스키마

## Goal

Next.js + Tailwind 프로젝트를 생성하고, SQLite DB 연결 및 reviews 테이블을 만든다.

## In Scope

- Next.js App Router 프로젝트 생성 (TypeScript)
- Tailwind CSS 설정
- better-sqlite3 설치 및 DB 초기화 모듈
- reviews 테이블 스키마 (id, title, rating, short_review, detail_review, watched_date, created_at, updated_at)
- DB 초기화 스크립트 또는 앱 시작 시 자동 생성
- 포트 3333 설정

## Out of Scope

- API route 구현
- UI 페이지 구현
- 테스트 코드

## Outputs

- `app/` 디렉터리 구조 (Next.js App Router)
- `lib/db.ts` — DB 연결 및 테이블 초기화
- `package.json` with dependencies
- `tailwind.config.ts`
- SQLite DB 파일 (gitignore 대상)

## Acceptance

- `npm run dev`로 Next.js가 포트 3333에서 실행된다
- better-sqlite3가 정상 import 된다
- 앱 시작 시 reviews 테이블이 자동 생성된다
- DB 스키마에 필요한 컬럼이 모두 존재한다
