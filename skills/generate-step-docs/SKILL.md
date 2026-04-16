---
name: generate-step-docs
description: master plan이 이미 존재하고, 이를 명확한 범위, 산출물, acceptance criteria를 가진 step-gated execution unit으로 분해해야 할 때 사용합니다.
---

# 스텝 문서 생성

## 개요

이 스킬은 master plan을 실행 가능한 step 단위로 분해합니다.

각 step은 executor와 verifier가 추측 없이 사용할 수 있을 만큼 명확해야 합니다.

## 사용 시점

- `docs/plans/master-plan.md`가 존재할 때
- 실행을 step-gated boundary로 나눠야 할 때
- 현재 master plan 기준으로 `docs/plans/steps/*.md`를 새로 만들거나 다시 써야 할 때

master plan이 아직 안정적이지 않다면 이 스킬을 사용하지 않습니다.

## 먼저 읽을 문서

- `CLAUDE.md`
- `docs/plans/master-plan.md`
- `docs/interview/development-interview-decisions.md`
- `templates/step-template.md`

## 핵심 규칙

각 step은 정확히 무엇이 이 step의 일인지, 무엇이 아닌지, 완료를 어떻게 확인할지를 정의해야 합니다.

## Step 크기 가이드

적절한 크기의 step은 다음 조건을 만족합니다:

- 한 세션 안에서 구현과 검증이 가능하다
- 하나의 논리적 계층 또는 관심사만 다룬다 (예: DB schema, API, UI, styling)
- acceptance criteria가 2~5개다. 그보다 적으면 step이 너무 모호하고, 그보다 많으면 나눠야 한다
- 이후 step과 독립적으로 테스트할 수 있는 output을 만든다

일반적인 소규모~중규모 프로젝트 기준 목표 범위는 **3~7 steps**입니다.

10개가 넘는 step이 나오면 verification clarity를 잃지 않는 범위에서 합칠 수 있는 곳을 찾습니다. 2개보다 적게 나오면 각 step 안에서 자연스러운 분리 지점을 찾습니다.

## 절차

1. master plan을 읽습니다
2. 위의 sizing guide를 사용해 자연스러운 execution boundary를 찾습니다
3. 각 boundary마다 step 문서 하나를 만듭니다
4. 각 step마다 아래를 정의합니다:
   - in-scope work
   - out-of-scope work
   - outputs: 이 step이 만드는 구체적 artifact (files, tables, endpoints, components)
   - acceptance: output이 실제로 동작함을 보여주는 관찰 가능한 체크. 각 항목에는 evidence type (`test`, `manual`, `command`, `file-check`)을 짝지어 둡니다
   - `depends_on`: 이 step이 입력으로 필요로 하는 prior step ID 목록
     - 전체 체인이 아니라 direct dependency만 적습니다
     - dependency가 없으면 `[]`를 사용합니다
5. step 문서를 `docs/plans/steps/` 아래에 씁니다

## 즉시 멈추는 경우

다음 경우에는 멈춥니다:

- master plan이 아직 분해하기에 충분히 안정적이지 않을 때
- 근거 없이 step acceptance를 지어내야 할 때
- step boundary가 너무 모호해서 gated execution을 지원할 수 없을 때

## 자동 진행 가능

다음 경우에는 계속 진행합니다:

- master plan이 step boundary를 분명하게 암시할 때
- acceptance를 confirmed plan scope와 연결할 수 있을 때

## 강한 규칙

- step이 쉽게 겹치도록 만들지 않습니다
- 다음 step의 작업을 현재 step에 넣지 않습니다
- 실행 근거 없는 acceptance를 쓰지 않습니다
- 모든 step의 `outputs`는 다음 step executor가 위치를 찾을 수 있을 만큼 구체적이어야 합니다
- `depends_on`은 단순 순서 선호가 아니라 실제 입력 필요를 반영해야 합니다

## 출력 형태

- `docs/plans/steps/` 아래의 하나 이상의 파일
- `docs/plans/planning-state.md`의 step-docs 단계를 `complete`로 갱신
- `implementation-start`로 execution을 시작할 수 있다는 명확한 안내

## 흔한 실수

- 한 세션에 구현과 검증이 어려울 정도로 step이 큰 것
- 너무 잘게 쪼개서 불필요한 오버헤드를 만드는 것
- out-of-scope boundary를 숨기는 것
- 검증할 수 없을 정도로 acceptance criteria가 모호한 것

## 성공 조건

이제 프로젝트를 전체 plan 위에서 자유주행하지 않고, step-by-step으로 실행할 수 있습니다.
