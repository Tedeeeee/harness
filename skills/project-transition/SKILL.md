---
name: project-transition
description: 이전 프로젝트가 완료(done)되었거나 새 프로젝트를 시작해야 할 때, docs 상태를 정리하고 새 프로젝트용으로 초기화하는 스킬입니다.
---

# 프로젝트 전환

## 개요

이 스킬은 이전 프로젝트의 docs 상태를 정리하고 새 프로젝트를 시작할 준비를 합니다.

코드를 작성하지 않습니다.

planning이나 implementation을 시작하지 않습니다.

## 사용 시점

- 이전 프로젝트가 done 상태이고 새 요구사항이 들어왔을 때
- implementation state가 없고 새 요구사항 파일이 존재할 때
- 사용자가 명시적으로 새 프로젝트 시작을 요청했을 때

이전 프로젝트가 아직 진행 중이라면 이 스킬을 사용하지 않습니다.

## 먼저 읽을 문서

- `CLAUDE.md`
- `docs/implementation/implementation-state.md`
- `docs/plans/planning-state.md` (있다면)
- `docs/requirements/` 아래 파일 목록
- `memory/project-memory.md`

## 핵심 규칙

이전 프로젝트의 산출물을 보존하면서 docs 상태를 깨끗하게 초기화합니다.

## 절차

1. 이전 프로젝트 상태 확인
   - implementation-state.md가 done인지 확인
   - done이 아니면 멈추고 사용자에게 확인

2. 이전 프로젝트 retrospective 확인
   - project-retrospective가 아직 안 됐으면 먼저 수행할지 사용자에게 묻기
   - 이미 됐거나 사용자가 건너뛰기를 선택하면 계속

3. docs 상태 초기화
   - `docs/plans/planning-state.md`를 템플릿에서 새로 생성
   - `docs/implementation/implementation-state.md`를 템플릿에서 새로 생성
   - `docs/plans/master-plan.md` 삭제
   - `docs/plans/steps/*.md` 삭제 (.gitkeep 유지)
   - `docs/interview/development-interview-decisions.md` 삭제
   - `docs/architecture/technical-approach.md` 삭제 (있다면)
   - `docs/verification/*.md` 삭제 (.gitkeep 유지)

4. 새 프로젝트 요구사항 확인
   - `docs/requirements/`에서 새 요구사항 파일 식별
   - planning-state.md의 Project와 Requirements File을 갱신

5. memory 보존
   - `memory/harness-memory.md`는 건드리지 않음
   - `memory/project-memory.md`는 새 프로젝트용으로 초기화
   - 이전 project-memory 내용 중 범용적인 것은 harness-memory로 승격 검토

## 즉시 멈추는 경우

- 이전 프로젝트가 done이 아닐 때
- 새 요구사항 파일이 없을 때
- 사용자가 전환을 확인하지 않았을 때

## 자동 진행 가능

- 이전 프로젝트가 done이고 retrospective도 완료되었고 새 요구사항이 있을 때

## 강한 규칙

- `experiments/` 아래 이전 프로젝트 코드는 건드리지 않음
- `memory/harness-memory.md`는 삭제하지 않음
- 이전 프로젝트의 requirements 원본은 삭제하지 않음 (archive 가능)
- 전환 도중 planning이나 implementation을 시작하지 않음
- docs 초기화 전에 이전 상태가 done인지 반드시 확인

## 출력 형태

- 초기화된 `docs/plans/planning-state.md`
- 초기화된 `docs/implementation/implementation-state.md`
- 정리된 plans, interview, architecture, verification 디렉터리
- 새 프로젝트 요구사항 식별 완료 메시지
- 다음 스킬: `assess-product-requirements`

## 흔한 실수

- 이전 프로젝트가 끝나지 않았는데 전환하는 것
- retrospective를 건너뛰고 memory 업데이트 기회를 놓치는 것
- experiments 아래 코드까지 삭제하는 것
- 새 요구사항 없이 전환만 하는 것

## 성공 조건

docs 상태가 깨끗하게 초기화되고, router가 새 프로젝트의 requirements assessment부터 시작할 수 있습니다.
