---
id: step-05
title: title-detail-screen
status: completed
screen_ids: [title-detail-top, title-detail-mid, title-detail-bottom]
visual_scope: approximate
depends_on: [step-01, step-02, step-03]
outputs:
  - `app/titles/[id]/page.tsx` — 작품 상세 라우트
  - `app/(components)/HeroSection.tsx` — 히어로 포스터 + 타이틀 + 별점 + 상단 아이콘 바(뒤로/검색, 공유 숨김)
  - `app/(components)/DetailTabs.tsx` — Synopsis / Cast / Similar 탭 내부 섹션 전환
  - `app/(components)/SynopsisPanel.tsx` — 요약 본문 + 메타 칩 + 확장된 메타 정보 표 + `View Summary`
  - `app/(components)/PlatformBadges.tsx` — 기본 숨김, 환경 플래그 `NEXT_PUBLIC_SHOW_PLATFORM_BADGES=true`일 때만 렌더
  - `app/(components)/SurveyBanner.tsx` 재사용 또는 variant
  - `app/(components)/CastList.tsx` — 이름-only
  - `app/(components)/SimilarSection.tsx` — `similarIds` 기반 가로 스크롤
  - `app/(components)/WatchNowBar.tsx` — 하단 고정, 전체폭 버튼, 하트 아이콘 숨김, `externalUrl`로 `target="_blank"`
acceptance:
  - 상세 라우트에서 히어로/탭/메타/설문 베너/Cast/Similar/Watch Now가 모두 렌더
  - 공유 아이콘이 DOM에 존재하지 않음
  - 하단 Watch Now 바에 하트 아이콘이 존재하지 않음, 버튼이 전체폭
  - Watch Now 버튼 href가 해당 작품의 `externalUrl`, `target="_blank"` 설정
  - 플랫폼 배지 블록은 환경 플래그 기본값(off)에서 렌더되지 않음
  - Cast 항목에 `Lead Cast` 등 역할 라벨이 나타나지 않음
---

# 스텝

## 목표

PDF p.4, p.5, p.1 하단 썸네일의 Title Detail 변경 지시를 단일 라우트/단일 페이지의 스크롤 상태로 구현한다.

## 범위 안

- `app/titles/[id]/page.tsx`에서 `getTitleById` 사용.
- 탭 전환은 페이지 내부 섹션 전환으로 구현(라우트 분리 없음).
- 메타 정보 표(Title / Genre / Release Year / Episodes / Country / Age Rating).
- 설문 베너는 Home 컴포넌트 재사용 또는 variant로 분리.
- Watch Now 하단 고정 바 + 외부 링크 연동.
- 플랫폼 배지 블록은 별도 컴포넌트 + 환경 플래그로 숨김 제어.
- Playwright 시나리오: 홈에서 카드 탭 → 상세 진입 → Watch Now href 검증(외부 이동은 호출 가로채기), 공유/하트 부재 검증, 스크롤 상태별 스크린샷.
- `CLAUDE.md`에 `NEXT_PUBLIC_SHOW_PLATFORM_BADGES` 플래그 기록.

## 범위 밖

- Similar 탭에서 추천 알고리즘(단순히 `similarIds` 목록 사용).
- 작품 공유/찜 저장(UI 요소 자체가 제외).
- 리뷰 작성·수정·삭제.
- 국제화 텍스트.

## 산출물

- 상기 컴포넌트와 라우트.
- Vitest: 상세 렌더 단위 테스트(공유 부재, 하트 부재, Cast 이름-only, 플랫폼 배지 플래그 동작).
- Playwright: 상세 흐름 시나리오 + 상/중/하 스크롤 상태 스크린샷 각 1장.
- `docs/verification/evidence/step-05/` 저장.

## 승인 기준

| Criteria | Evidence Type |
| --- | --- |
| `/titles/{id}` 라우트에서 히어로/탭/메타/설문베너/Cast/Similar/Watch Now가 모두 렌더 | test (Playwright) |
| 공유 아이콘과 하트 아이콘이 DOM에 존재하지 않음 | test (DOM 부재 검증) |
| Watch Now `href`가 해당 작품의 `externalUrl`이고 `target="_blank"` | test |
| `NEXT_PUBLIC_SHOW_PLATFORM_BADGES` 기본값에서 플랫폼 배지 블록이 렌더되지 않고, `true`일 때만 렌더 | test (두 경우 비교) |
| 스크롤 상단/중간/하단 3장의 모바일 스크린샷이 증거 폴더에 저장 | file-check |
