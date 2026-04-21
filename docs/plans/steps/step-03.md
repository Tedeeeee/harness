---
id: step-03
title: home-screen
status: completed
screen_ids: [home]
visual_scope: approximate
depends_on: [step-01, step-02]
outputs:
  - `app/page.tsx` (Home 라우트)
  - `app/(components)/Logo.tsx` — placeholder 텍스트/SVG
  - `app/(components)/SurveyBanner.tsx` — `NEXT_PUBLIC_SURVEY_URL` 참조, 부재 시 placeholder 값
  - `app/(components)/SearchBar.tsx` — 키워드 입력, Enter/검색 아이콘 시 `/search?q=`로 네비게이션
  - `app/(components)/PosterSection.tsx` — 섹션 헤더 + 가로 스크롤 포스터 카드
  - `app/(components)/PosterCard.tsx` — 포스터 + 타이틀 + `{EP} · Genre` + 별점
  - `app/(components)/BottomTabBar.tsx` — Home / Event(탐색) / Board(설문) 3개 탭, Account 없음
  - `.env.example`: `NEXT_PUBLIC_SURVEY_URL=https://example.invalid/survey`
acceptance:
  - Home 페이지가 `업데이트된 신작 → 인기작 픽 → 코리아 픽` 순으로 3개 섹션을 렌더
  - 최상단에 설문 베너가 고정 위치에 렌더되고 탭 시 설문 URL로 아웃바운드(target=_blank)
  - 하단 탭 바에 Home/Event/Board 세 개만 존재, Account 요소가 DOM에 없음
  - Event 탭 클릭 시 `/search` 경로로 이동
  - Board 탭 클릭 시 설문 URL로 아웃바운드
---

# 스텝

## 목표

PDF p.2의 Home 화면 변경 지시를 반영해 로고/검색바/설문 베너/3개 섹션/3탭 하단 바를 구축한다. 섹션 데이터는 step-02의 `getSection`으로 조회한다.

## 범위 안

- Home 라우트 구현 및 서버 컴포넌트 기본값 활용.
- 상단 구성: 로고 placeholder → 지구본 아이콘(UI only) → 검색바 → **설문 베너**(최상단 고정) 순.
- 섹션 렌더: `new-releases`, `popular-picks`, `korea-picks` 순으로 가로 스크롤 포스터 그리드.
- 하단 탭 바 고정 — 현재 라우트 하이라이트, Account 없음.
- 설문 URL 환경변수 주입 로직과 `.env.example` 샘플.
- `CLAUDE.md`에 환경변수 키와 placeholder 교체 지점 업데이트.

## 범위 밖

- Search/Filter 라우트 실제 구현(step-04).
- Title Detail 라우트(step-05).
- 이미지 최적화, 지역화 실제 언어 전환.
- 애니메이션/제스처 튜닝.

## 산출물

- 상기 컴포넌트 파일과 `app/page.tsx`.
- Vitest: 섹션 순서 렌더, 하단 탭 구성, 설문 베너 href 테스트.
- Playwright: Home 로드 시 섹션 순서·탭 구성·설문 베너 스크린샷 시나리오.
- `docs/verification/evidence/step-03/` 아래 Playwright 스크린샷.

## 승인 기준

| Criteria | Evidence Type |
| --- | --- |
| Home 페이지에서 3개 섹션이 지정된 순서(신작→인기작 픽→코리아 픽)로 렌더 | test (Vitest + Playwright) |
| 설문 베너 링크 href가 `NEXT_PUBLIC_SURVEY_URL` 값과 일치하고 `target="_blank"` | test |
| 하단 탭 바가 Home/Event/Board 3개만 존재(Account 없음) | test |
| Event 탭 클릭 시 `/search` 로 이동(Playwright 시나리오) | test |
| Home 모바일 뷰포트 스크린샷이 증거 폴더에 저장 | file-check |
