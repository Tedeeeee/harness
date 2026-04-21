---
name: generate-master-plan
description: 개발 인터뷰를 통해 충분한 confirmed decision이 쌓여 전체 구현 계획을 구조화할 수 있지만, 아직 master plan이 존재하지 않을 때 사용합니다.
---

# 마스터 플랜 생성

## 개요

이 스킬은 confirmed decision을 전체 implementation path로 구조화합니다.

작업을 정리합니다.

새로운 confirmed scope를 만들어내지는 않습니다.

## 사용 시점

- interview exit criteria가 충족되었을 때
- confirmed planning decision이 이미 존재할 때
- `docs/plans/master-plan.md`가 아직 없거나, confirmed decision을 바탕으로 생성되어야 할 때

아직 planning이 unanswered question 때문에 막혀 있다면 이 스킬을 사용하지 않습니다.

## 먼저 읽을 문서

- `CLAUDE.md`
- `docs/state-model.md`
- `docs/requirements/` 아래 최신 파일
- 존재한다면 `docs/architecture/technical-approach.md`
- `docs/interview/development-interview-decisions.md`
- `templates/master-plan-template.md`
- `memory/project-memory.md` (milestone 패턴, step sizing 기본값 등)
- `memory/harness-memory.md`

memory의 milestone 패턴이나 test 수용 기준이 이 프로젝트에 적용 가능하면 그 값을 default로 반영합니다. 단, interview decisions가 다른 값으로 confirmed라면 interview가 우선입니다. memory를 참조한 경우 `append_trace(event_type="memory-read", actor="generate-master-plan", reason=..., detail=참조한 memory 항목)`로 한 줄 기록합니다.

## 핵심 규칙

planning은 confirmed decision의 downstream입니다.

이 스킬은 decision을 plan으로 구조화합니다.

인터뷰를 대체하지는 않습니다.

## 절차

1. requirements, technical approach, interview decisions를 읽습니다
2. confirmed scope와 confirmed development rule을 추출합니다
3. 전체 execution direction을 정의합니다
4. milestone과 completion definition을 작성합니다
5. `docs/plans/master-plan.md`를 작성합니다

## 즉시 멈추는 경우

다음 경우에는 멈춥니다:

- key interview decision이 아직 unresolved 상태일 때
- plan completion criteria를 추측해야 할 때
- 제품 범위가 조용히 확장되어야 할 때

## 자동 진행 가능

다음 경우에는 계속 진행합니다:

- confirmed decision만으로 milestone을 정의하기 충분할 때
- 로컬 실행, 테스트, 문서화 기대치가 충분히 명확할 때

## 강한 규칙

- `open` 또는 `proposed` 항목을 `confirmed`로 승격하지 않습니다
- 새로운 product scope를 몰래 추가하지 않습니다
- completion criteria를 약화하지 않습니다
- 이 스킬에서 step doc은 만들지 않습니다

## 출력 형태

- `docs/plans/master-plan.md`
- `docs/plans/planning-state.md`의 master-plan 단계를 `complete`로 갱신
- `generate-step-docs`로의 명확한 handoff

## 흔한 실수

- 계획을 너무 일찍 쓰는 것
- guessed scope를 confirmed scope와 섞는 것
- plan을 두 번째 인터뷰처럼 만드는 것

## 성공 조건

confirmed decision을 반영하고 step decomposition을 지원하는 전체 implementation structure가 존재합니다.
