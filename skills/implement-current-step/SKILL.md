---
name: implement-current-step
description: implementation state 파일이 하나의 active step을 가리키고 있으며, 그 step의 in-scope work를 step boundary를 넘지 않고 구현해야 할 때 사용합니다.
---

# 현재 스텝 구현

## 개요

이 스킬은 active step만 구현합니다.

이 step을 verification-ready 상태로 준비합니다.

완료를 선언하지는 않습니다.

## 사용 시점

- `docs/implementation/implementation-state.md`가 존재할 때
- 정확히 하나의 step만 active 상태일 때
- 해당 step 안에서 execution을 계속해야 할 때

이미 verification-ready 상태이거나, step이 planning reason 때문에 blocked 상태라면 이 스킬을 사용하지 않습니다.

## 먼저 읽을 문서

- `START.md`
- `docs/plans/steps/` 아래 active step
- `docs/implementation/implementation-state.md`
- confirmed decision이 필요하면 `docs/interview/development-interview-decisions.md`
- active step에 `depends_on`이 있다면, 이미 만들어진 것을 이해하기 위해 해당 step들의 `outputs`와 verification docs

## 핵심 규칙

active step만 구현하고 `verification-ready`에서 멈춥니다.

## 절차

1. active step을 읽습니다
2. `depends_on`에 prior step이 있다면, 해당 step의 outputs와 verification docs를 읽어 prerequisite가 충족되었는지 확인합니다
   - prerequisite output이 빠졌거나 verification이 실패했다면 멈추고 `implementation-blocker`로 라우팅합니다
3. 이 step에 대한 verification document가 `docs/verification/` 아래 이미 있는지 확인합니다
   - 있고 `fail` 결과가 적혀 있다면, 먼저 fail reason과 failed acceptance item을 읽습니다
   - 실패한 항목만 고칩니다. 이미 passing인 항목은 다시 하지 않습니다
4. in-scope work만 구현합니다
5. out-of-scope 또는 future-step work는 피합니다
6. acceptance 기준으로 검증할 수 있게 준비합니다
7. step이 검사될 준비가 되면 `Current Status`를 `verification-ready`로 설정합니다

## 즉시 멈추는 경우

다음 경우에는 멈춥니다:

- step을 끝내려면 scope를 넘어야 할 때
- plan과 현실이 충돌할 때
- product scope가 바뀌어야 할 때
- 현재 step만으로 acceptance에 도달할 수 없을 때

## 자동 진행 가능

다음 경우에는 계속 진행합니다:

- 결정이 active step boundary 안에 머물 때
- 변경이 confirmed scope 안의 정상적인 implementation detail일 때

## 강한 규칙

- 다음 step을 미리 구현하지 않습니다
- `completed`를 선언하지 않습니다
- product scope를 조용히 확장하지 않습니다
- verification evidence를 `implementation-state.md`에 적지 않습니다

## 출력 형태

- active step에 대한 code, config, documentation 변경
- `in_progress`, `verification-ready`, `blocked` 중 하나를 나타내는 업데이트된 implementation state

## 흔한 실수

- 인접 step의 작업을 미리 해버리는 것
- 나중에 필요할 가능성이 높다는 이유로 현재 범위라고 착각하는 것
- verification 전에 완료라고 주장하는 것

## 성공 조건

active step이 `verify-current-step`으로 검사될 준비가 됩니다.
