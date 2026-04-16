---
name: implementation-start
description: step 문서가 이미 존재하고, step-gated implementation을 시작하거나 이어가기 위해 execution이 정확히 하나의 active step을 선택해야 할 때 사용합니다.
---

# 구현 시작

## 개요

이 스킬은 active execution step을 선택합니다.

작성된 step plan을 실제 실행을 위한 단일 current step으로 바꿉니다.

## 사용 시점

- step doc이 존재할 때
- 현재 active step이 없을 때
- execution이 막 시작되거나 재개되려 할 때

active step이 이미 진행 중인데 단순히 계속 구현하는 상황이라면, state recovery가 아닌 이상 이 스킬을 사용하지 않습니다.

## 먼저 읽을 문서

- `START.md`
- `docs/plans/master-plan.md`
- `docs/plans/steps/*.md`
- `templates/implementation-state-template.md`

## 핵심 규칙

동시에 active일 수 있는 step은 정확히 하나뿐입니다.

## 절차

1. step doc을 dependency 순서로 읽습니다
2. 시작이 허용된 첫 번째 pending step을 찾습니다
3. `docs/implementation/implementation-state.md`를 만들거나 업데이트합니다
4. 해당 step을 current active step으로 표시합니다
5. `Current Status`를 `in_progress`로 설정합니다

## 즉시 멈추는 경우

다음 경우에는 멈춥니다:

- step dependency가 불분명할 때
- 둘 이상의 step이 active처럼 보일 때
- 안전하게 활성화할 수 있는 pending step이 없을 때

## 자동 진행 가능

다음 경우에는 계속 진행합니다:

- step doc만 봐도 다음 허용 step이 분명할 때

## 강한 규칙

- 여러 step을 동시에 활성화하지 않습니다
- 막고 있는 dependency를 건너뛰지 않습니다
- 이 스킬에서 코드를 구현하지 않습니다
- 고정 상태값(`in_progress`, `verification-ready`, `blocked`, `done`)만 사용합니다

## 출력 형태

- 업데이트된 `docs/implementation/implementation-state.md`
- `implement-current-step`으로의 명확한 handoff

## 성공 조건

execution이 정확히 어떤 step을 active로 보고, 어떤 작업을 다음에 시작할 수 있는지 알게 됩니다.
