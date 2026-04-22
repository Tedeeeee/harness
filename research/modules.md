# 핵심 모듈 분석

## Hook Library

- **역할**: 하네스 상태 해석의 중심
- **위치**: `hooks/hooklib.py`
- **주요 함수**:
  - `get_implementation_summary()`: 구현 상태 문서에서 current step/status와 step 표를 파싱
  - `get_planning_summary()`: planning stage 상태 요약
  - `get_requirements_summary()`: 최신 requirements 문서와 status 추출
  - `get_memory_summary()`: 장기 기억 텍스트 병합
  - `detect_interrupt()`, `get_stop_guard_reason()`: 흐름 제어용 가드
  - `append_trace()`: `docs/trace/`에 이벤트 기록
- **다른 모듈과의 관계**: 모든 훅 엔트리 스크립트가 이 모듈을 공유한다.

## Hook Entrypoints

- **역할**: Claude 이벤트별 얇은 실행기
- **위치**: `hooks/session_start.py`, `hooks/user_prompt_submit.py`, `hooks/stop_guard.py`
- **주요 특징**:
  - 직접 상태를 파싱하지 않고 `hooklib`를 호출한다.
  - 출력은 추가 컨텍스트 JSON 또는 block decision이다.
- **다른 모듈과의 관계**: `.claude/settings.json`이 이 파일들을 이벤트에 연결한다.

## Docs State Model

- **역할**: 프로젝트 진행 상태의 canonical record
- **위치**: `docs/requirements/`, `docs/plans/`, `docs/implementation/`, `docs/verification/`
- **주요 특징**:
  - requirements, planning, implementation, verification을 문서로 분리
  - step별 evidence 디렉토리 운영
- **다른 모듈과의 관계**: 훅, 스킬, README 설명 전부 이 상태 모델을 전제로 한다.

## Moyza Data Layer

- **역할**: 작품 데이터, 홈 섹션, 필터 옵션의 단일 읽기 소스
- **위치**: `experiments/moyza-discovery/src/data/`
- **주요 파일**:
  - `titles.ts`: 15개 작품 시드
  - `home-sections.ts`: 홈 섹션 큐레이션
  - `filters.ts`: 필터 옵션 상수
  - `accessors.ts`: 조회/필터/섹션 조합 함수
  - `types.ts`: 도메인 타입 정의
- **다른 모듈과의 관계**: App Router 페이지와 UI 컴포넌트가 이 계층만 읽는다.

## Moyza UI Composition

- **역할**: 홈, 검색, 상세 화면을 조합하는 프레젠테이션 계층
- **위치**: `experiments/moyza-discovery/app/`, `experiments/moyza-discovery/src/components/`
- **주요 모듈**:
  - `app/page.tsx`: Home
  - `app/search/page.tsx`: 검색/필터
  - `app/titles/[id]/page.tsx`: 상세
  - `BottomTabBar.tsx`, `SynopsisPanel.tsx`, `FilterBar.tsx` 등: PDF 기반 주요 UI 조각
- **다른 모듈과의 관계**: `src/data/` 접근자와 `src/lib/env.ts`에 의존한다.

## Env Config Layer

- **역할**: 런타임 교체가 필요한 값 최소화
- **위치**: `experiments/moyza-discovery/src/lib/env.ts`
- **주요 함수**:
  - `getSurveyUrl()`
  - `isPlatformBadgesEnabled()`
- **다른 모듈과의 관계**: `BottomTabBar`, `SurveyBanner`, `PlatformBadges` 등 외부 링크/플래그 UI가 사용한다.

## Test Suites

- **역할**: 로직과 실제 화면 흐름을 각각 보증
- **위치**: `experiments/moyza-discovery/src/data/__tests__/`, `experiments/moyza-discovery/tests/unit/`, `experiments/moyza-discovery/tests/e2e/`
- **주요 특징**:
  - unit/component 테스트는 상세 UI 계약과 데이터 접근자를 검증
  - e2e는 Home → Search → Detail → 외부 링크 흐름을 회귀 검증
- **다른 모듈과의 관계**: verification 문서의 증거 소스로 사용된다.
