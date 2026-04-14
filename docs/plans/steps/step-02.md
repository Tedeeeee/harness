---
id: step-02
title: CRUD API 구현
status: draft
depends_on: [step-01]
outputs: [API routes for reviews CRUD, filter, sort]
acceptance: [모든 CRUD 엔드포인트 동작, 필터/정렬 쿼리 동작, Vitest 테스트 통과]
---

# Step 02 — CRUD API 구현

## Goal

영화 감상 기록의 생성, 조회, 수정, 삭제 API와 필터링/정렬 기능을 구현한다.

## In Scope

- `POST /api/reviews` — 새 감상 기록 생성
- `GET /api/reviews` — 목록 조회 (필터/정렬 쿼리 파라미터 포함)
  - 필터: rating_min, rating_max, date_from, date_to
  - 정렬: sort=latest|rating|title, order=asc|desc
- `GET /api/reviews/[id]` — 단건 조회
- `PUT /api/reviews/[id]` — 수정
- `DELETE /api/reviews/[id]` — 삭제
- 입력 검증 (제목 필수, 별점 1~5, 날짜 형식)
- Vitest 설치 및 API route 단위 테스트

## Out of Scope

- UI 페이지
- 페이지네이션 (목록이 충분히 작다고 가정)

## Outputs

- `app/api/reviews/route.ts` — 목록 조회 + 생성
- `app/api/reviews/[id]/route.ts` — 단건 조회 + 수정 + 삭제
- `lib/reviews.ts` — DB 쿼리 함수들
- `__tests__/api/reviews.test.ts` — API 테스트
- `vitest.config.ts`

## Acceptance

- 각 API 엔드포인트가 올바른 status code를 반환한다
- 필터링 (별점 범위, 날짜 범위)이 정확히 동작한다
- 정렬 (최신순, 별점순, 제목순)이 정확히 동작한다
- 유효하지 않은 입력에 적절한 에러 응답을 반환한다
- Vitest 테스트가 전부 통과한다
