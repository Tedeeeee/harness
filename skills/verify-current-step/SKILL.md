---
name: verify-current-step
description: active implementation step이 acceptance criteria 기준으로 검사될 준비가 되었고, 완료 여부를 주장 대신 evidence로 판단해야 할 때 사용합니다.
---

# 현재 스텝 검증

## 개요

이 스킬은 active step이 실제로 완료되었는지 판단합니다.

증거를 만듭니다.

직접 implementation work를 계속하지는 않습니다.

## 사용 시점

- active step이 존재할 때
- implementation이 verification-ready 상태일 때
- 하네스가 pass, fail, blocked 중 하나의 결과를 내려야 할 때

현재 step이 아직 구현되지 않았다면 이 스킬을 사용하지 않습니다.

## 먼저 읽을 문서

- `CLAUDE.md`
- `docs/plans/steps/` 아래 active step
- `docs/implementation/implementation-state.md`
- `templates/step-verification-template.md`

## 핵심 규칙

증거가 없으면 pass도 없습니다.

하나의 step에는 하나의 verification document가 있어야 합니다.

## 절차

1. active step의 acceptance criteria와 evidence type을 읽습니다
2. 각 acceptance item에 대해 지정된 방식으로 evidence를 수집합니다:
   - `test`: test command를 실행하고 output을 남깁니다
   - `manual`: 실제 상호작용을 수행하고 관찰 결과를 적습니다
   - `command`: CLI command를 실행하고 output을 남깁니다
   - `file-check`: file 또는 artifact가 존재하는지 확인하고 경로를 적습니다
   - evidence type이 지정되지 않았다면 가장 자연스러운 방법을 골라 어떤 type을 썼는지 적습니다
3. 아래 중 하나로 결정합니다:
   - `pass`
   - `fail`
   - `blocked`
4. 해당 step에 맞는 `docs/verification/step-xx-verification.md`를 작성하거나 업데이트합니다
5. `docs/implementation/implementation-state.md`를 업데이트합니다
6. step-status table에 verification document 파일명을 기록합니다

## 즉시 멈추는 경우

다음 경우에는 `blocked`로 멈춥니다:

- verification basis가 불명확할 때
- 필요한 evidence를 현재 수집할 수 없을 때
- planner 또는 user input 없이 step을 판단할 수 없을 때

## 자동 진행 가능

step이 pass이고 blocker가 없다면:

- step을 completed로 표시합니다
- 남은 step이 없을 때만 `Current Status`를 `done`으로 설정합니다
- 다음 pending step을 활성화할 수 있게 합니다

step이 fail이라면:

- fail reason과 failed acceptance item을 verification document에 씁니다
- `Current Status`를 다시 `in_progress`로 되돌립니다
- implementation state의 `Last Verification Result` 섹션에 fail summary를 기록합니다
- rework를 위해 제어를 `implement-current-step`으로 돌려보냅니다
- 해당 step은 `completed`로 두지 않습니다

같은 step이 verification에 **두 번 연속** 실패했다면:

- `implementation-blocker`를 통해 failure를 분류합니다
- blocker classification 없이 executor가 세 번째 시도를 하게 두지 않습니다

## 강한 규칙

- evidence 없이 pass를 선언하지 않습니다
- 만들어 낸 criteria로 검증하지 않습니다
- 이 스킬에서 계속 코딩하지 않습니다
- `implementation-state.md`를 verification document 대용으로 쓰지 않습니다
- `Verification Doc` 열에 `verified` 같은 status word를 쓰지 않습니다
- verification document가 없으면 step을 `completed`로 표시하지 않습니다

## 출력 형태

- `docs/verification/` 아래의 step별 verification document
- 고정 상태값만 사용해 업데이트된 implementation state
- 실제 verification document 파일명이 들어간 step table
- pass이고 blocker가 없다면 다음 step execution을 계속할 수 있다는 안내

## 흔한 실수

- “대충 된 것 같다”를 완료로 취급하는 것
- verification과 implementation을 섞는 것
- 실제로 acceptance를 확인하지 않았는데도 step을 pass시키는 것

## 성공 조건

현재 step이 완료되었는지 여부를, 저장된 verification document와 evidence를 바탕으로 하네스가 알 수 있습니다.
