# 아키텍처

## 디렉토리 구조

이 저장소는 단일 애플리케이션보다 운영 프레임워크와 산출물 앱이 함께 있는 구조다.

- `docs/`
  상태 기계의 현재값을 담는 공간이다. 요구사항, 시각 분석, 기술 접근, 인터뷰, 계획, 구현 상태, 검증 증거가 분리되어 있다.
- `hooks/`
  Claude 이벤트 훅이 문서 상태를 읽고 추가 컨텍스트를 만들어 주는 계층이다.
- `skills/`
  router, planner, executor, verifier, retrospective 역할을 나눈 작업 규칙 모음이다.
- `templates/`
  각 상태 문서의 형식 템플릿이다.
- `memory/`
  세션이 바뀌어도 재사용되는 규칙과 프로젝트별 기억을 저장한다.
- `experiments/moyza-discovery/`
  하네스로 구현한 결과물 앱이다. App Router 기반의 모바일 스트리밍 탐색 UI를 담는다.

## 설계 패턴

## 1. Docs-first orchestration

하네스는 “현재 무엇을 해야 하는가”를 코드가 아니라 문서 상태에서 읽는다. 예를 들어 planning 완료 여부는 `docs/plans/planning-state.md`, implementation 진행 상황은 `docs/implementation/implementation-state.md`, 검증 근거는 `docs/verification/`가 맡는다.

이 설계 덕분에 새 세션이 와도 문서를 읽으면 상태를 복원할 수 있고, hook이 그 상태를 기반으로 적절한 skill을 선택하도록 유도할 수 있다.

## 2. Thin event hooks over shared state logic

`hooks/session_start.py`, `hooks/user_prompt_submit.py`, `hooks/stop_guard.py`는 얇은 진입점이고, 실제 상태 해석 로직은 `hooks/hooklib.py`에 모여 있다. 훅 스크립트는 이벤트별로 공통 라이브러리를 호출해 JSON 컨텍스트를 반환하는 구조라 유지보수가 쉽다.

## 3. Experiment as isolated product slice

실제 UI 구현은 루트가 아니라 `experiments/moyza-discovery/`에 격리돼 있다. 하네스 자체는 범용 운영 프레임워크이고, 특정 프로젝트 산출물은 `experiments/`에 보관하는 식이다.

## 4. Static-data-first frontend

Moyza 실험 앱은 API나 DB 없이 `src/data/*.ts`에서 정적 데이터를 관리한다. 이는 MVP 속도와 docs-first 검증 흐름에 맞춘 선택이다.

## 레이어 구조

### 하네스 레이어

1. 사용자 입력
2. `docs/` 상태 문서
3. `hooks/` 상태 요약 및 가드
4. `skills/`에 정의된 역할 기반 행동
5. 결과를 다시 `docs/`와 `memory/`에 반영

### 실험 앱 레이어

1. `app/` 라우트
2. `src/components/` UI 조합
3. `src/data/` 정적 도메인 데이터와 접근자
4. `src/lib/env.ts` 환경 변수 해석
5. `tests/`의 unit/e2e 검증

## 아키텍처 결정 메모

- Next.js App Router와 포트 `3333`은 `docs/architecture/technical-approach.md`에서 명시적으로 확정되었다.
- 앱은 네이티브가 아니라 “앱처럼 느껴지는 웹”을 목표로 하며, CSS와 viewport 설정으로 이를 보강한다.
- 내부 API, 인증, CMS, 배포 인프라는 현 범위 밖으로 밀어두고 있다.
