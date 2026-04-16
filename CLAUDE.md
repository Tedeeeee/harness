# 셀프 하네스 시작점

당신은 docs-first 하네스를 운영하고 있습니다.

당신의 첫 번째 일은 기능을 지어내거나 곧바로 구현으로 뛰어드는 것이 아닙니다.

당신의 첫 번째 일은 세션이 바뀌어도 planning과 execution이 안전하게 이어질 수 있도록 state model을 존중하고 유지하는 것입니다.

## 운영 순서

1. 이전 프로젝트가 done이라면 `project-transition`으로 docs를 초기화합니다
2. `docs/requirements/` 아래에서 가장 최신의 human-authored requirements 문서를 읽습니다
3. 상세 planning을 시작하기 전에 기술 접근 방식을 먼저 확정합니다
4. planning을 안전하게 시작할 수 없다면 planner skill을 통해 질문합니다
5. `docs/plans/planning-state.md`로 planning 진행 상황을 추적합니다
6. decision이 confirmed된 뒤에만 planning 문서를 작성합니다
7. implementation 동안에는 step-gated execution을 사용합니다
8. 완료는 주장으로 닫지 말고 verification evidence로 닫습니다

## 협상 불가 규칙

### 1. 요구사항은 human input이다

`docs/requirements/` 아래 파일은 human-authored input입니다.

- 덮어쓰지 않습니다
- 제자리에서 풍부화하지 않습니다
- 추론한 scope를 사람이 쓴 것처럼 취급하지 않습니다

### 2. state model이 source of truth다

현재 상태를 복원할 때는 이 디렉터리의 docs를 사용합니다.

conversation memory만 믿지 않습니다.

### 3. planning과 execution은 분리된 역할이다

- Planner는 질문하고, 확인하고, 결정을 구조화합니다
- Executor는 active step만 구현합니다
- Verifier는 evidence로만 completion을 닫습니다

### 4. 완료에는 증거가 필요하다

verification evidence가 없으면 어떤 step도 완료가 아닙니다.

step별 verification은 `docs/verification/step-xx-verification.md`에 남겨야 합니다.

`docs/implementation/implementation-state.md`는 상태판이지 verification evidence의 대체물이 아닙니다.

### 5. hook은 전이를 자동화할 뿐 권한을 가지지 않는다

hook은 다음 owner를 자동으로 트리거할 수 있습니다.

scope를 발명하거나, evidence를 건너뛰거나, planner 승인 규칙을 우회하지는 않습니다.

## 범위

이 하네스는 다음을 사용합니다:

- docs-first state model
- 최소 skill 세트
- `hooks/` 아래의 첫 번째 hook 계층

앞으로의 업그레이드는 버전이 다른 새 하네스를 만드는 대신, 이 단일 하네스를 더 강하게 만드는 방향이어야 합니다.
