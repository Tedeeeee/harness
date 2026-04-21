# Product Requirements

## Metadata

- Status: confirmed
- Confirmed By: taesik (Moyza Discovery App 프로젝트 오너)
- Confirmed At: 2026-04-20
- Linked Planning State: `docs/plans/planning-state.md`

## Input Sources

- Primary Text Input: 사용자 요청 — "PDF 기준으로 작업해줘" + "화면 수나 포함 화면은 정리한 범위를 기준으로 먼저 requirements로 승격"
- Visual Source of Truth: `프로토타입_ux.pdf` (5페이지, 2026-04-20 제공)
- Notes:
  - 1차 분석은 `docs/visual-analysis/visual-source-analysis.md` 참조. 본 문서는 그 분석을 scope로 승격한 결과.
  - 확정되지 않은 값은 `[undecided]` 또는 `placeholder`로 남김. 확정 시 본 문서를 업데이트.

## Goal

Moyza 스타일의 **모바일 스트리밍 작품 탐색 앱**을, 전달드릴 브랜드로 리스킨하고 Home·검색/필터·작품 상세 3개 화면과 설문지 중심 프로모션 베너를 갖춘 형태로 구축한다.

## Problem

OTT/드라마 이용자가 여러 플랫폼에 흩어진 작품 정보를 한 곳에서 훑어보고 원하는 작품을 외부 플랫폼으로 바로 이동할 수 있게 해야 한다. 동시에 운영팀은 프로모션/설문지 베너를 통해 사용자 리서치와 캠페인을 수집할 통로가 필요하다. 현재 Moyza 원본 UI에는 사용하지 않는 섹션·액션(Account 탭, 찜, 공유, 과도한 Home 섹션)이 섞여 있어 MVP 범위와 어긋난다.

## Users

- Primary user: 한국/아시아 드라마·영화 탐색을 즐기는 **모바일 시청자**. 작품을 검색/필터/카테고리로 탐색하고 원하는 플랫폼으로 바로 이동하려는 목적.
- Secondary user: 설문·프로모션 응답을 수집하려는 **운영/마케팅 담당자** (설문 베너 링크 운영).

## Core Features

1. **Home 화면**
   - 최상단: 전달드릴 로고([undecided] 자산 대기) + 언어/지역 토글(지구본 아이콘) + 키워드 검색바.
   - 검색바 바로 아래에 **설문지 링크용 베너**를 고정 배치. 베너 탭 시 설문 URL([placeholder-survey-url])로 이동.
   - 섹션 순서(상단→하단): `업데이트된 신작` → `인기작 픽` → `코리아 픽`. 그 외 기존 섹션(예: Trends)은 비활성.
   - 각 섹션은 가로 스크롤 포스터 카드, 카드에는 `TOP` 배지(해당 시), 타이틀, `{EP} · Genre`, 별점 표시.
   - 하단 탭 3개: `Home` / `Event`(탐색 아이콘) / `Board`(설문지 아이콘). `Event` 탭 탭 시 검색/필터 화면으로 라우트 이동. `Board` 탭 탭 시 설문 URL([placeholder-survey-url])로 이동. `Account` 탭 없음.

2. **검색 + 필터 결과 화면**
   - 상단: 뒤로가기 + 키워드 입력바(검색 아이콘).
   - `Filter` 접힘/펼침 섹션. 카테고리 세 줄: `Country`(초기 옵션: USA / Korea / China / Japan), `Genre`(Romance / Horror / Action / Comedy / B/L), `Platform`(초기 옵션: A / B / C / D / E — 실제 플랫폼명은 `[undecided]`, 확정 전까지 이 더미 라벨 사용).
   - `Platform` 칩은 **텍스트만** 사용(배경 칩 스타일·아이콘 없음).
   - `Results N` + `Latest first` 정렬 드롭다운.
   - 결과는 3열 포스터 그리드(타이틀 캡션 포함), 무한 스크롤 또는 페이지네이션([undecided]).

3. **작품 상세 화면 (단일 페이지, 세로 스크롤)**
   - 상단 히어로 이미지 + 타이틀 + 별점(`★ 5.0 (207건 리뷰)` 형태).
   - 상단 아이콘 바: 뒤로가기, 검색. **공유 아이콘 숨김**.
   - 탭: `Synopsis / Cast / Similar` (탭 전환은 화면 내부 섹션 전환).
   - Synopsis 섹션: 요약 본문 + 메타 칩(`19+ · 2025 · 20 EP · Drama · More`) + (조건부) 플랫폼 배지 블록(NETFLIX / TVING / coupang play 등).
     - 플랫폼 배지 블록 MVP 기본값: **숨김**. `[undecided]` — 일정에 따라 노출 여부 재확정.
   - 설문 베너: Synopsis 하단에 `Join now and get a free Americano!` 베너 재사용, 설문 URL([placeholder-survey-url]) 삽입. 홈 베너와 동일/다른 URL 여부 `[undecided]`.
   - Cast 섹션: 출연진 이름만 표기. `Lead Cast` 등 역할 라벨 제거.
   - Similar 섹션: 연관 작품 리스트(형식 `[undecided]` — 기본 가정: 포스터 가로 스크롤).
   - 확장된 Synopsis 상태에서는 메타 정보 표(Title / Genre / Release Year / Episodes / Country / Age Rating)와 `View Summary` 토글 노출.
   - 하단 고정 바: `Watch Now` 버튼(전체폭, 중앙 정렬). 하트(찜) 아이콘 **숨김**. Watch Now는 해당 작품의 외부 플랫폼 URL로 이동(데이터 소스 `[undecided]`, 초기에는 작품 레코드의 `externalUrl` placeholder 사용).

4. **설문/프로모션 링크 운영**
   - 홈 최상단 베너, `Board` 탭, 작품 상세 Synopsis 하단 베너 세 지점에서 설문 URL로 이동.
   - URL 값·단일/복수 여부는 `[undecided]`. 최초 구현은 단일 placeholder URL을 환경변수로 관리하고 이후 분리 가능한 구조로 둔다.

## Out of Scope

- `Account` 탭 및 관련 페이지(프로필, 인증, 구독 관리 등).
- 홈의 `Trends` 외 기타 원본 Moyza 섹션.
- 작품 상세의 공유 기능, 찜(하트)/즐겨찾기 기능.
- 앱 내 결제·구독·로그인 플로우.
- 운영자용 콘텐츠 입력/편집 도구(CMS).
- 푸시 알림, 리뷰 작성/편집, 댓글.
- "개발 기간에 따라 숨김 처리" 대상인 상세 플랫폼 배지 블록은 MVP에서 기본 숨김 — 향후 결정 시 재포함.

## Constraints

- Schedule constraint: `[undecided]` — 납품 기한은 미정. 일정 확정 시 상세 플랫폼 배지 노출 여부도 함께 결정.
- Technical constraint:
  - 모바일(iOS Safari/크롬 등) 세로형 뷰포트 기준 다크 테마. 정확한 전달 형태(네이티브 앱 vs 모바일 반응형 웹)는 `select-technical-approach`에서 확정. 현재 기본 가정은 **모바일 반응형 웹**.
  - 로고·플랫폼 아이콘·이미지 자산 일부는 사용자가 추후 전달(`[undecided]` — 전달드릴 로고, 플랫폼 이름/아이콘).
  - 국제화(다국어)는 지구본 토글 UI만 유지하고 실제 로케일 데이터는 `[undecided]` — MVP 기본 한국어 단일 로케일.
- Operational constraint:
  - 설문/베너 URL은 환경변수 또는 운영 설정으로 주입 가능해야 운영팀이 앱 재배포 없이 교체할 수 있다.
  - 콘텐츠 데이터(작품, 포스터, 메타, 플랫폼 URL)는 최초 MVP에서 정적 시드 데이터로 제공([undecided] — 이후 API 연동 시점).

## Success Criteria

- 사용자가 Home 화면에서 설문지 베너를 1탭으로 열 수 있다.
- 사용자가 Home 상단 검색바 또는 하단 `Event` 탭으로 검색/필터 화면에 진입할 수 있다.
- 검색/필터 화면에서 Country·Genre·Platform 필터를 조합해 결과 목록이 갱신되고, 정렬은 `Latest first` 기본.
- 결과 카드 탭 시 작품 상세로 이동한다.
- 작품 상세에서 `Watch Now` 탭 시 해당 작품의 외부 플랫폼 URL이 새 창/외부 브라우저로 열린다(placeholder URL 허용).
- 작품 상세에서 Synopsis/Cast/Similar 탭 전환이 동작하고, Cast 리스트는 이름만 노출된다.
- 하단 탭 바에 Home / Event / Board 3개만 표시되고 Account 관련 UI는 전체 앱에 존재하지 않는다.
- 설문 URL·전달드릴 로고 자산을 받은 뒤 코드 레벨 대체 없이 설정값/자산 교체만으로 반영할 수 있다.

## Screen Coverage

- Included screens:
  1. Home
  2. Search + Filter Results
  3. Title Detail (단일 화면, 스크롤 상태: 포스터+Watch Now / 베너+Cast / 확장 Synopsis+메타표)
  4. 하단 탭 내비게이션 (Home / Event(탐색) / Board(설문) — 레이아웃 요소)
- Excluded screens:
  - Account 탭 / Account 페이지 (PDF 명시)
  - Home의 `Trends` 및 3개 확정 섹션 이외 영역 (PDF 명시)
  - 작품 상세 공유 아이콘 액션 (PDF 명시)
  - 작품 상세 하트/찜 액션 (PDF 명시)
  - 작품 상세 플랫폼 배지 블록 (MVP 기본 숨김, 일정 확정 시 재평가)
- Open visual ambiguities (→ 후속 단계에서 해결):
  - 설문 링크 URL(단일 vs 복수), 내부 뷰 vs 외부 URL 구분
  - `Watch Now` 링크의 데이터 소스 필드명
  - 전달드릴 로고 자산 수령 시점과 파일 포맷
  - `Platform` 필터 옵션 실제 이름 5종
  - `코리아 픽` 섹션 큐레이션 기준 (국가 필터 파생 vs 편집 큐레이션)
  - `Event` 탭 전환 UX (라우트 이동 가정 유지)
  - MVP에서 플랫폼 배지 블록 최종 노출 여부
  - `Similar` 탭 레이아웃 세부
  - 검색 결과 페이지네이션/무한스크롤 선택
