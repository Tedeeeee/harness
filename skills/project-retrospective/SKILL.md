---
name: project-retrospective
description: 모든 step이 완료되고 implementation state가 done인 뒤, 프로젝트를 돌아보며 재사용 가능한 교훈을 memory에 남기고 닫아야 할 때 사용합니다.
---

# 프로젝트 회고

## 개요

이 스킬은 완료된 프로젝트를 검토하고 재사용 가능한 지식을 memory로 추출합니다.

새 작업을 시작하지 않습니다.

다음 프로젝트가 이번 프로젝트의 학습을 활용할 수 있도록 learning loop를 닫습니다.

## 사용 시점

- `docs/implementation/implementation-state.md`에 `Current Status: done`이 있을 때
- `docs/implementation/implementation-state.md`의 `Current Step`이 `none`일 때
- `docs/plans/planning-state.md`의 `Planning Final Status: closed`일 때
- `docs/plans/planning-state.md`의 `Requirements Confirmed: yes`일 때
- 모든 step이 verification doc과 함께 `completed` 상태일 때
- 프로젝트가 아직 review되지 않았을 때

위 다섯 조건 중 하나라도 어긋나면 이 스킬을 시작하지 않고 `verify-current-step` 또는 `assess-product-requirements`로 돌려보냅니다. 여전히 active이거나 pending인 step이 있다면 이 스킬을 사용하지 않습니다.

## 먼저 읽을 문서

- `docs/implementation/implementation-state.md`
- `docs/verification/` 아래 모든 verification doc
- `docs/interview/development-interview-decisions.md`
- `docs/plans/master-plan.md`
- `docs/plans/steps/*.md`
- `docs/trace/` 아래 이 프로젝트가 커버되는 기간의 trace 파일
- `memory/project-memory.md`
- `memory/harness-memory.md`

## 핵심 규칙

확인되었거나 반복된 것만 추출합니다. 추측이나 일회성 사고는 저장하지 않습니다.

## 절차

1. 모든 verification doc에서 fail 또는 blocked 결과를 훑습니다
   - 어떤 step이 rework를 거쳤고 이유가 무엇인지 기록합니다
2. interview decision에서 패턴을 찾습니다
   - 어떤 tech choice가 만들어지고 confirmed되었는지
   - 어떤 decision이 프로젝트를 넘어 반복해서 나타났는지
3. step doc에서 sizing과 dependency 패턴을 봅니다
   - step 크기가 적절했는지, 나누거나 합쳐야 했는지
   - dependency가 정확했는지, executor가 예상치 못한 문제를 만났는지
4. **Memory Candidate Review**: 이 프로젝트를 커버하는 trace 파일에서 반복된 결정을 추출합니다
   - 같은 결정이 trace에 3회 이상 나타나면 후보로 제안
   - 사용자 명시 요청이 있었다면 즉시 승격 후보
   - 카테고리(`user | feedback | project | reference`)를 함께 제안
5. 발견한 내용을 세 버킷으로 분류합니다:
   - **project-memory**: 이 프로젝트 유형에 특화된 tech convention, 반복 decision, 반복 blocker
   - **harness-memory**: 앞으로 모든 프로젝트에 적용해야 할 하네스 운영 규칙 또는 선호
   - **discard**: 일회성 사실, 이미 고쳐진 이슈, 코드에서 바로 유도 가능한 것
6. 후보를 사용자에게 보여주고 승인을 받습니다 (memory 승격은 사용자 승인 전까지 이루어지지 않습니다)
7. project-memory 항목이 승인되면 `memory/project-memory.md`를 업데이트합니다. 각 항목은 카테고리 태그를 갖습니다.
8. 새로운 안정 패턴이 confirmed된 경우에만 `memory/harness-memory.md`를 업데이트합니다
9. 승격된 각 항목에 대해 `append_trace(event_type="memory-promoted", actor="project-retrospective", reason=..., detail=...)`로 trace 기록
10. 이미 memory에 있는 내용을 중복해서 넣지 않습니다

## 무엇을 추출할 것인가

다음은 저장합니다:

- confirmed되었고 반복 가능성이 높은 tech choice (예: "SQLite for local-only apps")
- 반복된 blocker pattern (예: "Windows path issues with hook runtime")
- step sizing lesson (예: "UI steps should split list view and form into separate steps")
- 매번 물어야 했고 다음엔 기본값이 될 수 있는 interview question
- 사용자를 놀라게 했거나 수동 보정이 필요했던 harness workflow

## 무엇을 추출하지 않을 것인가

다음은 저장하지 않습니다:

- 코드에서 바로 유도 가능한 implementation detail
- 한 번만 발생했고 이미 고쳐진 bug
- git history나 commit summary
- 이미 existing memory에 문서화된 내용

## 강한 규칙

- implementation, plan, verification 문서를 수정하지 않습니다
- 새로운 planning이나 execution을 시작하지 않습니다
- speculative lesson을 저장하지 않습니다. confirmed되었거나 반복된 패턴만 저장합니다
- 기존 memory entry를 덮어쓰지 않습니다. 업데이트하거나 append합니다
- 중복을 피하기 위해 항상 먼저 existing memory를 확인합니다

## 출력 형태

- 발견 내용을 사용자에게 보여주는 요약
- 프로젝트별 교훈이 있으면 업데이트된 `memory/project-memory.md`
- 하네스 수준 교훈이 있으면 업데이트된 `memory/harness-memory.md`
- 프로젝트 review가 완료되었다는 명확한 문장

## 흔한 실수

- 재사용 가능한 패턴만 골라야 하는데 모든 것을 저장하는 것
- 일회성 debugging session을 반복 가능한 lesson으로 취급하는 것
- 기존 memory와 중복되는 entry를 또 쓰는 것
- review를 건너뛰고 바로 다음 프로젝트로 넘어가는 것

## 성공 조건

memory가 confirmed된 재사용 가능 lesson으로 업데이트되고, 다음 프로젝트의 planner와 interviewer가 이번 경험을 활용할 수 있습니다.
