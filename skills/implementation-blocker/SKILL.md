---
name: implementation-blocker
description: execution 또는 verification을 정상적으로 계속할 수 없고, 이 문제가 implementation, planning, scope, external condition 중 어디에 속하는지 하네스가 분류해야 할 때 사용합니다.
---

# 구현 차단 이슈 분류

## 개요

이 스킬은 blocked 상태를 분류합니다.

실행이 다음 중 어디로 가야 하는지 결정합니다:

- 현재 step 안에서 계속 수정하기
- planning으로 되돌아가기
- planner 로직을 통해 사용자 입력 요청하기

## 사용 시점

- executor가 더 이상 안전하게 계속할 수 없을 때
- verifier가 `blocked`를 반환했을 때
- implementation과 plan이 충돌하는 것처럼 보일 때

## 먼저 읽을 문서

- `CLAUDE.md`
- active step doc
- `docs/implementation/implementation-state.md`
- `docs/interview/development-interview-decisions.md`
- `docs/plans/master-plan.md`

## 핵심 규칙

executor가 사용자와 직접 scope를 협상하면 안 됩니다.

막힌 작업은 먼저 분류해야 합니다.

## 절차

1. blocker를 점검합니다
2. 아래 중 하나로 분류합니다:
   - implementation detail issue
   - plan conflict
   - scope change
   - external environment issue
3. 다음 owner를 결정합니다:
   - executor
   - planner
   - planner를 통한 user input
4. implementation state에 blocker 기록을 업데이트합니다

## 즉시 멈추는 경우

다음 경우에는 멈추고 executor 밖으로 라우팅합니다:

- product scope가 바뀌어야 할 때
- confirmed plan boundary가 더 이상 현실과 맞지 않을 때
- 사용자 승인이 필요할 때

## 자동 진행 가능

다음 경우에는 executor가 계속 진행하도록 둡니다:

- blocker가 로컬 implementation detail에 불과할 때
- scope나 plan 의미를 바꾸지 않고도 active step을 끝낼 수 있을 때

## 강한 규칙

- executor가 product-scope decision을 조용히 흡수하게 두지 않습니다
- plan conflict를 “implementation detail”로 숨기지 않습니다

## 출력 형태

- blocker classification
- 다음 action에 대한 recommended owner
- blocker note가 반영된 implementation state

## 성공 조건

하네스가 계속 구현할지, planning으로 돌아갈지, 사용자 입력을 요청할지 판단할 수 있습니다.
