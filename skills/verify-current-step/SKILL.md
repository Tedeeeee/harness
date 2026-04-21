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
- `docs/visual-analysis/visual-source-analysis.md` (있는 경우)
- `templates/visual-fidelity-checklist-template.md` (visual 프로젝트인 경우)

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
3. visual-source 프로젝트라면 아래 "Visual Pass 절차"를 같이 수행합니다
4. 아래 중 하나로 결정합니다:
   - `pass`
   - `fail`
   - `blocked`
5. 해당 step에 맞는 `docs/verification/step-xx-verification.md`를 작성하거나 업데이트합니다
6. `docs/implementation/implementation-state.md`를 업데이트합니다
7. step-status table에 verification document 파일명을 기록합니다

## Visual Pass 절차

`docs/visual-analysis/visual-source-analysis.md`가 존재하면 이 절차는 **필수**입니다.

1. 현재 step 문서의 `screen_ids`와 `visual_scope`를 읽습니다
   - `screen_ids`가 비어 있으면 시각 검증은 `not-applicable`로 기록하고 다음 단계로 진행
2. `visual-source-analysis`에서 대상 screen의 Mandatory Changes와 Core Visible Elements를 읽습니다
3. `templates/visual-fidelity-checklist-template.md`의 6개 카테고리(coverage, spacing, hierarchy, tab bar, banner, typography)를 각 screen에 대해 평가합니다
4. `visual_scope` 엄격도에 따라 카테고리별 pass/fail을 결정합니다
5. step verification 문서의 `시각 검증` 섹션에 대상 screen IDs, 카테고리 표, 증거(스크린샷 경로 또는 수동 관찰 노트)를 기록합니다
6. 모든 대상 screen × 모든 카테고리 중 하나라도 fail이면 시각 검증 결과는 fail입니다
7. `implementation-state.md`의 `Last Verification Result.Visual Pass`를 `pass | fail | not-run`으로 갱신합니다
   - `screen_ids`가 비어 있는 step이면 `n/a`로 기록

functional 결과와 visual 결과는 둘 다 반영되어야 step이 completed로 갈 수 있습니다. 둘 중 하나라도 fail이면 step은 completed로 표시되지 않습니다.

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

## Closure 전환 규칙

마지막 step이 pass 처리되어 `Current Status`를 `done`으로 전환하는 경우, 같은 절차 안에서 다음을 **한 트랜잭션으로** 처리합니다. 하나라도 실패하면 closure를 완료로 보고하지 않고 blocked로 표시합니다.

1. `docs/implementation/implementation-state.md`:
   - `Current Step`을 `none`으로 비움
   - `Current Status`를 `done`으로
   - `Next Allowed Action`을 `start-retrospective`로 고정
2. `docs/plans/planning-state.md`:
   - `Planning Final Status`를 `closed`로
3. visual-source 프로젝트(`docs/visual-analysis/visual-source-analysis.md` 존재)라면 모든 completed step이 verification 문서에 visual 검증 결과를 갖고 있어야 함. 하나라도 시각 검증이 빠졌거나 fail이면 closure 전환을 거부하고 step을 completed로 되돌린 뒤 blocked로 보고.
4. `Last Verification Result.Visual Pass`가 `pass` 또는 `n/a` 상태여야 함. `not-run` 또는 `fail`이면 closure 전환 거부.

두 문서 중 하나만 바뀐 상태로 끝나면 `stop_guard`가 closure mismatch로 차단합니다.

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

## Trace

`templates/trace-entry-template.md` 포맷으로 다음 이벤트를 기록합니다:

- 시각 검증이 적용되어 결과가 확정된 경우: event_type `visual-pass`, actor `verify-current-step`, reason `pass|fail|not-applicable`, detail는 대상 step id와 screen IDs
- closure 전환이 일어난 경우: event_type `closure`, actor `verify-current-step`, reason `implementation-state done, planning-state closed`, detail는 해당 step id

## Parallel Verification (Optional)

functional 검증과 visual 검증은 독립 에이전트로 병렬 실행할 수 있습니다 (`docs/parallelism-contract.md` 참조). 규칙:

- 각 에이전트는 read-only로 acceptance와 visual checklist를 해석하고 evidence를 수집합니다
- step verification document 작성은 **단일 writer**가 두 결과를 합쳐 수행합니다
- 병렬 시작/종료 시 `parallel-start` / `parallel-join` trace를 기록합니다

## 흔한 실수

- “대충 된 것 같다”를 완료로 취급하는 것
- verification과 implementation을 섞는 것
- 실제로 acceptance를 확인하지 않았는데도 step을 pass시키는 것

## 성공 조건

현재 step이 완료되었는지 여부를, 저장된 verification document와 evidence를 바탕으로 하네스가 알 수 있습니다.
