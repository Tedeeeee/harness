# 작업 이력 (Changelog)

## 2026-04-22

### 작업 내용

- 프로젝트 전반을 다시 읽고 `research/` 문서를 신규 생성했다.
- 하네스 운영 시스템과 `experiments/moyza-discovery/` 실험 앱을 함께 다루는 구조로 문서를 정리했다.
- Codex가 먼저 읽을 수 있도록 `AGENTS.md`를 추가하고, 기존 `CLAUDE.md`에는 research 참조를 연결했다.
- 하네스가 Claude Design 같은 HTML/JSX/CSS 프로토타입 코드 입력을 공식적으로 분석할 수 있도록 skill/template/root guidance 계약을 확장했다.

### 의사결정 기록

- **결정**: research 문서는 하네스와 실험 앱을 분리해서 설명하되, 둘의 연결점(`docs` 상태 모델이 실험 앱 구현을 제어함)을 중심으로 작성한다.
- **이유**: 이 저장소는 단순한 Next.js 앱이 아니라 운영 프레임워크와 산출물이 결합된 형태라, 앱만 설명하면 구조를 오해하기 쉽다.
- **결정**: 프로토타입 코드는 `최종 구현 계약`이 아니라 `요구사항 초안 입력`으로 취급한다.
- **이유**: 화면/상태/데이터/인터랙션 정보는 강하게 활용하되, `alert()`나 하드코딩 값 같은 데모 구현을 그대로 제품 요구로 굳히지 않기 위해서다.

### 알려진 이슈

- `docs/trace/trace-2026-04-22.md`는 훅 실행 중 자동 생성된 untracked 파일이다.
- 공식 문서 상태상 구현은 완료됐지만 retrospective는 아직 시작되지 않았다.

## 2026-04-21

### 작업 내용

- 운영 문서 retrofit과 함께 step-05, step-06, step-07 verification 문서에 시각 검증 계약을 소급 반영했다.
- `implementation-state.md` 기준 step-07까지 모두 완료 처리되었고 Current Status가 `done`으로 닫혔다.

### 의사결정 기록

- **결정**: 앱 느낌 보강은 재플랫폼이 아니라 CSS/viewport 중심의 app-feel visual pass로 해결한다.
- **이유**: 기존 Next.js 구현과 테스트 자산을 유지하면서 PDF의 iOS 앱 느낌을 최대한 가깝게 맞추기 위함.

## 최근 커밋 흐름

- `83e7c78` `upgrade harness workflow and add moyza experiment`
- `08176fc` `add harness follow-up notes`
- `4afc69e` `strengthen harness docs and add movie log run`
- `52872fd` `add runtime hooks for self-harness`
