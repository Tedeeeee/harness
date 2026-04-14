---
id: step-03
title: UI 구현
status: draft
depends_on: [step-02]
outputs: [목록 페이지, 작성/수정 폼, 삭제 확인, 필터/정렬 UI]
acceptance: [브라우저에서 CRUD 전체 흐름 동작, 필터/정렬 UI 동작]
---

# Step 03 — UI 구현

## Goal

감상 기록 목록, 작성/수정 폼, 필터/정렬 컨트롤을 브라우저에서 사용할 수 있게 만든다.

## In Scope

- 메인 페이지: 감상 기록 목록 (카드 또는 리스트 형태)
- 새 기록 작성 폼 (제목, 별점, 한줄평, 상세 리뷰, 감상 날짜)
- 기록 수정 폼 (기존 값 로드)
- 삭제 확인 UI
- 필터 컨트롤 (별점 범위, 날짜 범위)
- 정렬 컨트롤 (최신순, 별점순, 제목순)
- 빈 상태 안내 (기록이 없을 때)

## Out of Scope

- 반응형 세부 조정 (step-04에서 처리)
- 테스트 추가

## Outputs

- `app/page.tsx` — 메인 목록 페이지
- `app/reviews/new/page.tsx` — 새 기록 작성
- `app/reviews/[id]/edit/page.tsx` — 기록 수정
- `components/` — ReviewCard, ReviewForm, FilterBar, SortControl 등

## Acceptance

- 새 감상 기록을 작성하고 목록에서 확인할 수 있다
- 기존 기록을 수정할 수 있다
- 기록을 삭제할 수 있다
- 필터 (별점, 날짜)를 적용하면 목록이 갱신된다
- 정렬을 변경하면 목록 순서가 바뀐다
- 기록이 없을 때 안내 메시지가 표시된다
