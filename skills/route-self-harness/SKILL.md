---
name: route-self-harness
description: 사용자 요청이 들어왔고, prompt와 문서 상태를 함께 보고 planning, execution, verification, blocker 처리 중 어떤 스킬이 다음 action을 맡아야 하는지 하네스가 결정해야 할 때 사용합니다.
---

# 셀프 하네스 라우팅

## 개요

이 스킬은 최상위 traffic controller입니다.

직접 작업을 수행하지 않습니다.

다음 스킬을 고릅니다.

## 사용 시점

- 새로운 요청이 들어왔을 때
- 현재 문서 상태를 맥락으로 삼아 요청을 해석해야 할 때
- 여러 단계가 가능하고 다음 owner를 골라야 할 때

## 먼저 읽을 문서

- `CLAUDE.md`
- `docs/state-model.md`
- `docs/document-lifecycle.md`
- `docs/plans/planning-state.md` (있다면)
- `docs/implementation/implementation-state.md` (있다면)
- `docs/` 아래 현재 문서들

## 핵심 규칙

prompt만이 아니라 `prompt + state`로 라우팅합니다.

## 절차

1. 현재 docs state를 확인합니다
2. 사용자 요청을 확인합니다
3. 다음 단계가 무엇인지 결정합니다:
   - requirements authoring
   - requirements assessment
   - technical approach selection
   - development interview
   - master planning
   - step decomposition
   - implementation start
   - current-step execution
   - verification
   - blocker handling
   - project retrospective
4. 정확히 하나의 스킬로 handoff합니다

## 라우팅 규칙

### 전환

- implementation state가 done이고 새 requirements 파일이 있다면 -> `project-transition`
- implementation state가 done이고 retrospective가 아직 안 됐다면 -> `project-retrospective`

### planning (planning-state.md 기반)

- requirements 문서가 없으면 -> `author-product-requirements`
- requirements는 있지만 planning-state의 requirements가 not-assessed라면 -> `assess-product-requirements`
- requirements는 충분하지만 planning-state의 technical-approach가 not-started라면 -> `select-technical-approach`
- technical-approach가 complete이지만 interview가 not-started라면 -> `conduct-development-interview`
- planning-state에 blocked 단계가 있다면 -> `conduct-development-interview`
- interview가 complete이고 master-plan이 not-started라면 -> `generate-master-plan`
- master-plan이 complete이고 step-docs가 not-started라면 -> `generate-step-docs`

### planning (planning-state.md 없이 fallback)

- requirements는 있지만 planning이 아직 시작되지 않았다면 -> `assess-product-requirements`
- requirements는 충분하지만 technical approach 문서가 없다면 -> `select-technical-approach`
- technical approach는 있지만 interview decisions 문서가 없다면 -> `conduct-development-interview`
- interview가 끝났고 master plan이 없다면 -> `generate-master-plan`
- master plan은 있지만 step doc이 없다면 -> `generate-step-docs`

### 실행

- step doc은 있지만 active step이 없다면 -> `implementation-start`
- active step이 있고 할 일이 남아 있다면 -> `implement-current-step`
- active step이 verification에 실패했고 다시 `in_progress`로 돌아왔다면 -> `implement-current-step` (rework)

### 검증

- active step이 verification-ready라면 -> `verify-current-step`
- 같은 step이 verification에 두 번 연속 실패했다면 -> `implementation-blocker`
- 현재 state가 blocked라면 -> `implementation-blocker`

### 완료

- 모든 step이 completed이고 implementation state가 done이라면 -> `project-retrospective`

## 강한 규칙

- 단계를 가볍게 건너뛰지 않습니다
- planning이 불완전한데 바로 implementation으로 라우팅하지 않습니다
- 모든 “continue” 요청을 똑같이 다루지 않습니다. current state를 이용해 해석합니다

## 출력 형태

- 선택된 다음 스킬
- current state에 근거한 짧은 이유

## 성공 조건

하네스가 언제나 가장 자연스러운 단일 다음 action을 알 수 있습니다.
