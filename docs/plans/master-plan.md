# Master Plan — 개인 영화 감상 기록 앱

## Goal

영화 감상 기록을 CRUD로 관리하고, 필터·정렬로 조회할 수 있는 1인용 로컬 웹 앱을 완성한다.

## Direction

Next.js App Router 기반 풀스택 앱. SQLite를 better-sqlite3로 직접 접근하고, Tailwind CSS로 반응형 UI를 구성한다. 서버 사이드에서 DB를 다루고, 클라이언트는 fetch로 API route를 호출한다.

## Included Scope

- 영화 감상 CRUD (제목, 별점, 한줄평, 상세 리뷰, 감상 날짜)
- 감상 목록 조회
- 별점 범위 필터링, 감상 날짜 범위 필터링
- 최신순, 별점순, 제목순 정렬
- 반응형 레이아웃 (모바일 대응)
- API route 단위 테스트 (Vitest)
- README (설치·실행 방법)

## Non-Goals

- 외부 영화 검색 API (TMDB 등)
- 위시리스트
- 통계 / 차트
- 사용자 인증
- 클라우드 배포
- E2E 테스트

## Development Rules

- Next.js 14+ App Router 사용
- SQLite + better-sqlite3 (직접 SQL)
- Tailwind CSS
- Vitest로 API route 테스트
- README에 설치·실행 방법 기록
- 포트 3333 사용 (사용자 선호)

## Milestones

1. 프로젝트 초기화 및 DB 스키마 — Next.js 프로젝트 생성, SQLite 연결, 테이블 생성
2. API 구현 — CRUD API route 완성 + 필터/정렬 쿼리
3. UI 구현 — 목록 페이지, 작성/수정 폼, 필터/정렬 컨트롤
4. 반응형 및 마무리 — 모바일 레이아웃, 테스트, README

## Risks

- better-sqlite3는 네이티브 모듈이라 Windows에서 빌드 도구(node-gyp) 필요 가능
- SQLite 파일 경로가 Next.js dev 모드에서 핫리로드 시 잠길 수 있음

## Completion Definition

- 로컬에서 `npm run dev`로 앱 실행 가능
- 감상 기록 생성, 조회, 수정, 삭제 동작
- 필터링(별점, 날짜)과 정렬(최신순, 별점순, 제목순) 동작
- 모바일 브라우저에서 레이아웃 정상
- API route 테스트 통과
- README에 설치·실행 방법 기재
