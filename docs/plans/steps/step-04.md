---
id: step-04
title: search-filter-screen
status: completed
screen_ids: [search-filter-results]
visual_scope: approximate
depends_on: [step-01, step-02, step-03]
outputs:
  - `app/search/page.tsx` — 검색/필터 라우트, `q` 쿼리 스트링 지원
  - `app/(components)/FilterBar.tsx` — Country / Genre / Platform 칩 UI, Platform은 텍스트-only
  - `app/(components)/FilterHeader.tsx` — 뒤로가기 + 키워드 입력
  - `app/(components)/SortDropdown.tsx` — `Latest first` 기본
  - `app/(components)/ResultsGrid.tsx` — 3열 포스터 카드 그리드 + 결과 수 표기
acceptance:
  - Event 탭 또는 Home 검색바에서 `/search`로 진입 시 기본 목록 렌더
  - Country/Genre/Platform 칩 AND 조합으로 결과가 축소·갱신
  - Platform 칩이 배경 없이 텍스트-only로 렌더
  - `Results N` 카운트가 현재 결과 수와 일치
  - `Latest first` 정렬이 year desc 순으로 적용
---

# 스텝

## 목표

PDF p.3의 Search/Filter 화면을 구축하고 Event 탭 네비게이션을 연결한다. 필터 로직은 step-02의 `filterTitles`에 위임한다.

## 범위 안

- `/search` 라우트 및 쿼리 스트링 연동(`q`).
- FilterBar: 세 줄(Country/Genre/Platform) 칩. 각 칩 토글 시 로컬 상태 업데이트.
- Platform 칩: 텍스트-only 스타일(배경/아이콘 없음).
- 결과 그리드: 3열 포스터 + 캡션.
- 정렬 드롭다운(`Latest first` 기본).
- 결과 카드 탭 시 `/titles/[id]`로 네비게이션(라우트는 step-05에서 구현되지만 링크 href는 이 step에서 준비).
- Home 검색바 제출 시 `/search?q=<keyword>`로 이동 확인.

## 범위 밖

- 무한 스크롤/페이지네이션(MVP 범위에서 전체 목록 일괄 렌더).
- Title Detail 화면 실제 구현.
- 플랫폼 아이콘/로고 표시.
- 필터 카테고리의 접기/펼치기 상세 애니메이션.

## 산출물

- 상기 컴포넌트와 `app/search/page.tsx`.
- Vitest: 필터 조합, 정렬, 빈 결과 케이스 컴포넌트 테스트.
- Playwright: Event 탭 클릭 → `/search` 이동, 칩 토글 → 결과 수 변화, Latest first 정렬 확인 스크린샷.
- `docs/verification/evidence/step-04/` 스크린샷.

## 승인 기준

| Criteria | Evidence Type |
| --- | --- |
| Event 탭에서 `/search`로 이동하고 초기 결과 목록이 렌더 | test (Playwright) |
| Country+Genre+Platform 각 칩을 토글하면 `Results N`이 정확한 값으로 갱신 | test |
| Platform 칩이 배경·아이콘 없이 텍스트-only 스타일로 렌더 | test (DOM 클래스/스타일 검증) |
| 결과 카드 href가 `/titles/{id}`를 가리킴 | test |
| 모바일 뷰포트 Playwright 스크린샷 저장 | file-check |
