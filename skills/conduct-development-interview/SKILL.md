---
name: conduct-development-interview
description: 제품 요구사항과 기술 접근 방식이 이미 계획 시작에 충분하지만, 계획에 중요한 개발 결정이 아직 남아 있어 한 번에 하나씩 사용자와 상호작용하며 수집해야 할 때 사용합니다.
---

# 개발 인터뷰 진행

## 개요

이 스킬은 요구사항 평가와 기술 방향 고정 이후에도 남아 있는 planning-critical gap을 메웁니다.

확정된 결정을 수집합니다.

아직 implementation plan을 작성하지는 않습니다.

## 사용 시점

- requirements가 계획 시작에 충분할 때
- 여전히 key development decision이 빠져 있을 때
- 안전하게 plan generation을 시작하기 전에 planner가 질문을 해야 할 때

인터뷰 종료 조건이 이미 충족된 뒤에는 이 스킬을 사용하지 않습니다.

## 먼저 읽을 문서

- `CLAUDE.md`
- `docs/state-model.md`
- `docs/document-lifecycle.md`
- `docs/requirements/` 아래 최신 파일
- 존재한다면 `docs/architecture/technical-approach.md`
- `templates/development-interview-decisions-template.md`

## 핵심 규칙

한 번에 정확히 하나의 planning-critical question만 묻습니다.

사용자가 명시적으로 답하거나 승인한 내용만 `confirmed`로 기록합니다.

## 절차

1. 현재 requirements 문서를 읽습니다
2. 기술 접근 방식 문서가 있으면 읽습니다
3. 아직 해결되지 않은 planning gap 중 가장 중요한 하나를 찾습니다
4. 정확히 하나의 질문만 합니다
5. 옵션 `1`, `2`, `3`, `4. user direction`을 포함합니다
6. 결과를 `docs/interview/development-interview-decisions.md`에 기록합니다
7. 계획이 더 이상 막히지 않을 때까지 반복합니다

## 인터뷰 종료 조건

아래가 충족될 때만 인터뷰를 끝낼 수 있습니다:

- key tech choice가 결정되었을 때
- test expectation이 결정되었을 때
- documentation scope가 결정되었을 때
- 남은 unresolved item이 implementation planning을 막지 않을 때

## 즉시 멈추는 경우

다음 경우에는 멈추고 사용자에게 묻습니다:

- product scope가 바뀌어야 할 때
- 명시적 승인 없이 어떤 결정을 `confirmed`로 표시하려 할 때
- planning-critical gap이 여전히 안전한 plan generation을 막을 때

## 자동 진행 가능

다음 경우에는 인터뷰를 계속합니다:

- 다음 누락 항목을 질문 하나로 해결할 수 있을 때
- 현재 결정이 product scope가 아니라 planning detail에 해당할 때

## 강한 규칙

- 질문은 한 번에 하나만 합니다
- 질문을 묶지 않습니다
- 추측을 `confirmed`로 표시하지 않습니다
- `docs/architecture/technical-approach.md`에 이미 확정된 기술 결정을 scope change 없이 다시 열지 않습니다
- 이 스킬에서 plan 문서를 만들지 않습니다
- AI가 먼저 빠진 항목을 제기했고 사용자가 승인했다면 `ai-raised-approved-by-user`로 기록합니다

## 출력 형태

- 옵션 `1`, `2`, `3`, `4`가 있는 질문 하나
- 또는 업데이트된 interview decisions 문서, `docs/plans/planning-state.md`의 interview 단계를 `complete`로 갱신, 그리고 `generate-master-plan`으로의 명확한 handoff

## 흔한 실수

- 인터뷰를 plan으로 바꿔버리는 것
- 한 메시지에 여러 질문을 넣는 것
- 추론한 답을 confirmed로 기록하는 것
- 구현 세부 사항을 무조건 product scope로 취급하는 것

## 성공 조건

승인되지 않은 가정에 의존하지 않고 planning을 시작할 수 있습니다.
