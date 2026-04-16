---
name: assess-product-requirements
description: 사람이 작성한 요구사항 마크다운 파일이 이미 있고, 계획을 안전하게 시작할 수 있는지 또는 먼저 하나의 차단 질문을 해야 하는지 판단해야 할 때 사용합니다.
---

# 제품 요구사항 평가

## 개요

이 스킬은 planner의 첫 번째 게이트입니다.

사람이 작성한 요구사항 문서를 읽고, 계획을 안전하게 진행할 수 있는지 판단합니다.

계획 문서를 작성하지는 않습니다.

## 사용 시점

- `docs/requirements/` 아래에 요구사항 마크다운 파일이 이미 있을 때
- 하네스가 계획 단계로 계속 진행할지 판단해야 할 때
- 하나의 차단 질문을 해야 하는지, 아니면 다음 planner 단계로 넘어가도 되는지 알고 싶을 때

요구사항 문서가 아직 없다면 이 스킬을 사용하지 않습니다.

## 먼저 읽을 문서

- `CLAUDE.md`
- `docs/state-model.md`
- `docs/document-lifecycle.md`
- `docs/requirements/`

## 핵심 규칙

이 스킬은 오직 하나의 질문에만 답합니다.

`현재 요구사항만으로 계획을 안전하게 계속 진행할 수 있는가?`

답이 아니오라면 멈추고 정확히 하나의 차단 질문만 합니다.

답이 예라면 기술 접근 방식 선택 단계로 넘깁니다.

## 절차

1. `docs/requirements/` 아래에서 가장 최신의 human-authored requirements markdown 파일을 고릅니다
   - `README.md`는 무시합니다
   - `.gitkeep` 같은 dotfile도 무시합니다
2. 문서를 고정된 human input으로 읽습니다
3. 문서가 아래 계획 근거를 충분히 제공하는지 확인합니다:
   - goal
   - problem
   - users
   - core features
   - out of scope
   - constraints
   - success criteria
4. planner 게이트를 적용합니다:
   - 계획이 제품 범위 추측에 의존해야 한다면 멈춥니다
   - step acceptance를 쓸 근거가 부족하다면 멈춥니다
   - 그 외에는 계속 진행합니다
5. 아래 둘 중 하나만 반환합니다:
   - `sufficient -> continue to technical approach selection`
   - `insufficient -> ask one blocking question`

## 즉시 멈추는 경우

다음 경우에는 멈추고 질문합니다:

- 제품 범위를 추측해야만 할 때
- 중요한 planning decision이 빠져 있어서 안전한 다음 단계 진행을 막을 때
- 현재 요구사항 때문에 이후 계획 문서가 acceptance criteria를 지어내야 할 때

## 자동 진행 가능

다음 경우에는 다음 planner 단계로 진행합니다:

- 문서만으로 technical approach selection을 시작하기에 충분할 때
- 부족한 세부 정보는 이후 한 질문씩 묻는 방식으로 수집해도 될 때

## 강한 규칙

- 요구사항 문서를 다시 쓰지 않습니다
- 요구사항 내용을 제자리에서 풍부화하지 않습니다
- 이 스킬에서 `docs/interview/`, `docs/plans/`, 구현 문서를 만들지 않습니다
- 질문을 묶어서 하지 않습니다
- 요구사항이 부족하다면 우선순위가 가장 높은 차단 질문 하나만 합니다

## 출력 형태

### 충분한 경우

- 선택한 requirements 파일을 식별합니다
- `docs/plans/planning-state.md`의 requirements 단계를 `complete`로 갱신합니다
- technical approach selection을 시작하기에 충분하다고 말합니다
- 다음 스킬 이름을 적습니다: `select-technical-approach`

### 부족한 경우

- 선택한 requirements 파일을 식별합니다
- `docs/plans/planning-state.md`의 requirements 단계를 `blocked`로 갱신합니다
- 아직 충분하지 않다고 말합니다
- 정확히 하나의 차단 질문만 합니다

## 흔한 실수

- sufficiency check를 implementation plan처럼 바꾸는 것
- fixed input이어야 할 requirements를 다시 쓰는 것
- 여러 질문을 한 번에 묻는 것
- 구현 세부 정보가 빠졌다고 항상 planning이 막힌다고 보는 것

## 성공 조건

하네스가 아래 둘 중 하나를 분명하게 결정할 수 있습니다:

- 다음 planner 단계로 계속 진행하기
- 하나의 차단 질문과 함께 멈추기
