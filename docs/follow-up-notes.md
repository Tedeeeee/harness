# Harness Follow-up Notes

## 목적

이 문서는 다음 작업 세션에서 하네스를 어떤 순서로 보강해야 하는지 빠르게 이어가기 위한 메모다.

## 현재 상태 요약

- `router -> planner -> executor -> verification` 기본 루프는 동작한다.
- runtime hook(`session-start`, `user-prompt-submit`, `stop-guard`)은 실제로 작동한다.
- `memory/` 레이어는 추가되었지만, 아직 행동 변화를 강하게 만들 정도로 활용되지는 않는다.
- `docs/verification/step-xx-verification.md` 문서가 생성되도록 계약을 보강했다.
- generated project는 `experiments/` 아래에 생성되도록 운영 중이다.

## 현재 확인된 약점

### 1. 문서 계약이 아직 완전히 고정되지 않음

- `implementation-state.md`가 상태판 역할만 해야 하는데, 여전히 검증 결과나 예외 메모가 섞일 가능성이 있다.
- step 문서의 `status` 같은 메타데이터가 실행 후에도 정리되지 않는 경우가 있다.
- `confirmed`, `auto default`, `user skip` 같은 결정 상태의 의미가 아직 충분히 분리되지 않았다.

### 2. hook이 상태 문서 포맷에 민감함

- `Blockers`에 `- None` 대신 다른 표현이 들어가면 `stop-guard`가 blocker로 해석할 수 있다.
- 현재 hook은 잘 동작하지만, 문서 형식이 조금만 흔들려도 과민 반응할 수 있다.

### 3. memory가 실제 행동 변화로 아직 충분히 연결되지 않음

- 지금은 memory를 읽는 수준이다.
- planner/router가 memory를 활용해 질문을 줄이거나 기본값을 재사용하는 장면은 아직 약하다.

### 4. requirements 작성 단계가 아직 암묵적임

- 현재는 요구사항이 없을 때 자연스럽게 requirements 초안을 만들고 있지만,
- 별도 `requirements authoring` skill로 명확히 분리되지는 않았다.

### 5. 사용자 인터럽트 상태가 없음

- 작업 도중 사용자가 새 요청을 넣었을 때,
- 이것을 `blocked`로 볼지, 별도 인터럽트 상태로 볼지 아직 정식 설계가 없다.

### 6. 관측성(Observability)이 부족함

- 어떤 hook이 개입했는지
- 어떤 skill이 왜 선택됐는지
- memory가 실제로 영향을 줬는지
- 나중에 추적하기 어렵다.

## 다음 작업 우선순위

### 우선순위 1. 문서 계약 고정

- `implementation-state.md`는 상태판 역할만 하도록 더 강하게 제한
- step 문서의 `status` 메타데이터 업데이트 규칙 정리
- 인터뷰 문서에서 `confirmed`와 `assumed default` 분리
- `user skip` 또는 `verified-with-skip` 같은 상태 표현 필요 여부 결정

### 우선순위 2. 사용자 인터럽트 처리 모델 추가

추천 방향:

- `blocked`와 별개로 `interrupted_by_user` 상태 추가 검토
- `implementation-state.md`에 `User Interruption` 섹션 추가 검토
- `user-prompt-submit`에서 단순 승인/계속과 실제 인터럽트를 구분
- 새 요청 처리 후 기존 step으로 복귀하는 규칙 정의

### 우선순위 3. memory를 실제 행동 변화로 연결

- planner가 반복 질문을 줄이도록 memory 활용
- blocked 대응 방식에 memory 적용
- project memory를 통해 반복 기술 선택 재사용

### 우선순위 4. observability/log 추가

- 어떤 hook이 실행됐는지
- 어떤 state를 읽었는지
- memory를 사용했는지
- 간단한 로그를 남기는 방식 검토

### 우선순위 5. requirements authoring skill 분리

- requirements가 없을 때의 초안 작성 규칙을 별도 skill로 명시
- 현재 planner 앞단의 암묵 동작을 명문화

## 내일 시작할 때 추천 순서

1. 이 문서를 다시 읽고 현재 우선순위 확인
2. `implementation-state-template.md`와 관련 skill 계약 다시 점검
3. `interrupted_by_user` 상태 모델을 설계할지 결정
4. 가능하면 작은 테스트 프로젝트 하나로 다시 검증

## 내일 바로 확인할 질문

- `blocked`와 `interrupted_by_user`를 분리할 것인가?
- `confirmed`와 `assumed default`를 문서에서 어떻게 구분할 것인가?
- memory 사용 흔적을 어떤 형식으로 남길 것인가?

## 한 줄 정리

지금 하네스는 큰 그림과 기본 루프는 성공했고, 다음 단계는 기능 추가보다 `운영 계약`, `인터럽트 처리`, `memory 활용`, `관측성`을 단단하게 만드는 것이다.
