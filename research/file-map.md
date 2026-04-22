# 파일 맵

핵심 파일 위주 레퍼런스다. 전체 파일 목록이 아니라 수정 진입점이 되는 파일만 정리한다.

## 루트

| 파일 | 역할 |
|------|------|
| `README.md` | 하네스 운영 개요와 디렉토리 설명 |
| `CLAUDE.md` | Claude Code용 최상위 운영 계약 |
| `.claude/settings.json` | Claude 이벤트 훅 wiring |

## docs/

| 파일 | 역할 |
|------|------|
| `docs/requirements/moyza-discovery-app.md` | 현재 실험 앱의 확정 요구사항 |
| `docs/visual-analysis/visual-source-analysis.md` | PDF 분석 결과 |
| `docs/architecture/technical-approach.md` | 기술 선택 기록 |
| `docs/plans/planning-state.md` | planning 단계 전체 상태 |
| `docs/plans/master-plan.md` | 마일스톤 계획 |
| `docs/plans/steps/step-01.md` ~ `step-07.md` | step 단위 구현 범위 |
| `docs/implementation/implementation-state.md` | 현재 구현 상태판 |
| `docs/verification/step-01-verification.md` ~ `step-07-verification.md` | step 검증 결과 |

## hooks/

| 파일 | 역할 |
|------|------|
| `hooks/hooklib.py` | 문서 상태 파싱, 가드, trace 공통 라이브러리 |
| `hooks/session_start.py` | 세션 시작 컨텍스트 생성 |
| `hooks/user_prompt_submit.py` | 사용자 프롬프트 제출 시 상태 기반 라우팅 힌트 생성 |
| `hooks/stop_guard.py` | 너무 이른 종료 차단 |
| `hooks/test_hooklib.py` | hooklib 테스트 |

## experiments/moyza-discovery/app/

| 파일 | 역할 |
|------|------|
| `app/layout.tsx` | 앱 레이아웃과 viewport 메타 |
| `app/globals.css` | 앱 느낌을 만드는 전역 스타일 |
| `app/page.tsx` | Home 화면 |
| `app/search/page.tsx` | Search + Filter 화면 |
| `app/titles/[id]/page.tsx` | 상세 화면 |

## experiments/moyza-discovery/src/components/

| 파일 | 역할 |
|------|------|
| `BottomTabBar.tsx` | Home / Event / Board 하단 탭 |
| `SearchBar.tsx` | 홈 상단 검색 진입 |
| `PosterSection.tsx` | 홈 가로 섹션 |
| `FilterHeader.tsx` | 검색 페이지 헤더 |
| `FilterBar.tsx` | Country / Genre / Platform 칩 |
| `ResultsGrid.tsx` | 검색 결과 3열 그리드 |
| `HeroSection.tsx` | 상세 상단 히어로 |
| `DetailTabs.tsx` | Synopsis / Cast / Similar 탭 |
| `SynopsisPanel.tsx` | 상세 요약, 메타, 베너, More 토글 |
| `CastList.tsx` | 이름-only 캐스트 리스트 |
| `SimilarSection.tsx` | 연관 작품 목록 |
| `WatchNowBar.tsx` | 하단 고정 외부 링크 바 |

## experiments/moyza-discovery/src/data/

| 파일 | 역할 |
|------|------|
| `titles.ts` | 작품 시드 데이터 |
| `home-sections.ts` | 홈 큐레이션 구성 |
| `filters.ts` | 필터 옵션 상수 |
| `accessors.ts` | 조회/필터/섹션 접근자 |
| `types.ts` | 도메인 타입 |

## tests/

| 파일 | 역할 |
|------|------|
| `src/data/__tests__/accessors.test.ts` | 데이터 접근자 로직 검증 |
| `tests/unit/home.test.tsx` | Home 컴포넌트 계약 검증 |
| `tests/unit/search.test.tsx` | Search/Filter 계약 검증 |
| `tests/unit/detail.test.tsx` | Detail 화면 세부 계약 검증 |
| `tests/e2e/regression.spec.ts` | 핵심 사용자 여정 회귀 테스트 |
| `tests/e2e/app-feel.spec.ts` | 앱 느낌과 뷰포트 관련 시각 테스트 |
