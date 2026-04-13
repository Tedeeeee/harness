# Design: Self Harness v1

Generated on 2026-04-13
Status: APPROVED
Scope: Experiment

## Goal

기존 하네스에 의존하지 않고, 요구사항 문서를 실행 가능한 계획 문서 세트로 변환하는 최소 하네스를 별도 실험 폴더에서 검증한다.

v1의 목표는 자동 구현이 아니라 다음 루프를 안정적으로 만드는 것이다.

1. 요구사항 템플릿 문서를 입력으로 받는다.
2. 전체 개발 방향을 담은 상위 계획 문서 1개를 만든다.
3. 각 단계별 실행 문서 여러 개를 만든다.
4. 사용자가 Claude와 대화하면서 상위/하위 문서를 수정할 수 있다.
5. 수정은 즉시 반영과 제안 후 승인 두 방식을 모두 지원한다.

## Why This Version

첫 버전은 범용 에이전트 프레임워크를 만드는 것이 아니라, 계획 루프를 문서 중심으로 고정하는 실험이어야 한다.

이 방식의 장점은 다음과 같다.

- 코드 자동 수정, 테스트 자동화, PR 생성 없이도 하네스의 핵심인 계획 품질을 검증할 수 있다.
- 문서가 곧 상태이므로 별도 데이터베이스나 런타임 없이 시작할 수 있다.
- 나중에 실행, 검증, 출하 루프를 얹기 쉬운 구조를 만든다.

## Success Criteria

v1이 성공했다고 보기 위한 기준은 다음과 같다.

1. 구조화된 요구사항 템플릿 하나만으로 상위 계획 문서가 생성된다.
2. 상위 계획 문서로부터 순서가 있는 하위 단계 문서들이 생성된다.
3. 사용자가 "범위를 줄여줘", "2단계를 먼저 하자" 같은 요청을 하면 문서 수정 루프가 돈다.
4. 상위 계획 변경이 하위 단계 문서에 어떤 영향을 주는지 Claude가 설명하고 동기화할 수 있다.
5. 산출물이 사람이 검토하고 계속 다듬을 수 있는 문서 형태로 남는다.

## Non-Goals

v1에서는 다음을 다루지 않는다.

- 실제 코드 자동 생성 또는 수정
- 테스트 자동 실행
- Git 브랜치, 커밋, PR 자동화
- 멀티 에이전트 오케스트레이션
- 웹 UI 또는 상태 저장용 별도 DB

## Core Design

### 1. Input Interface

입력은 자유형 메모가 아니라 계획 생성용 템플릿 문서로 고정한다.

템플릿은 사람이 쓰기 쉬운 문서보다 Claude가 빠짐없이 계획을 만들기 쉬운 구조를 우선한다. 따라서 필수 섹션, 선택 섹션, 빈칸 예시를 명확히 둔다.

### 2. Primary Outputs

출력은 두 계층으로 나눈다.

- 상위 계획 문서 1개
  - 전체 목표
  - 범위 / 비범위
  - 단계 분해
  - 리스크
  - 완료 정의
- 하위 단계 문서 N개
  - 단계 목표
  - 선행 조건
  - 입력과 산출물
  - 구현 방향
  - 검토 포인트
  - 다음 단계로 넘길 정보

상위 문서는 전략 문서, 하위 문서는 실행 카드로 본다.

### 3. Revision Modes

수정 루프는 두 가지를 지원한다.

- Direct update
  - 사용자의 요청을 반영해 문서를 바로 갱신한다.
- Propose then apply
  - Claude가 먼저 수정 제안을 작성하고, 사용자 승인 후 문서를 갱신한다.

기본 동작은 `제안 -> 승인 -> 반영`으로 둔다.

### 4. Synchronization Rule

이 하네스의 핵심 규칙은 문서 정합성이다.

- 상위 계획이 바뀌면 Claude는 하위 단계 문서 중 어떤 문서가 영향을 받는지 먼저 판단한다.
- 하위 단계 문서를 수정할 때도 상위 계획과 충돌하는지 먼저 설명한다.
- 상위 계획과 하위 단계 문서는 항상 같은 방향을 가리켜야 한다.

즉, 이 시스템은 단순 문서 생성기가 아니라 계획 동기화 엔진이다.

## Proposed Folder Layout

실험 폴더는 다음과 같이 구성한다.

```text
experiments/self-harness-v1/
  README.md
  templates/
    requirements-template.md
    master-plan-template.md
    step-template.md
  docs/
    requirements/
      sample-requirement.md
    plans/
      master-plan.md
      steps/
        01-setup.md
        02-...
  instructions/
    generate-master-plan.md
    generate-step-docs.md
    revise-plan.md
```

## Document Metadata

상태 파일 없이도 정렬과 동기화를 가능하게 하기 위해, 각 하위 단계 문서에는 최소 메타데이터를 둔다.

예시:

```md
---
id: step-01
title: 프로젝트 초기 설정
status: draft
depends_on: []
outputs:
  - template files
  - initial plan set
acceptance:
  - plan scope is clear
  - next step is executable
---
```

필수 후보 메타데이터:

- `id`
- `title`
- `status`
- `depends_on`
- `outputs`
- `acceptance`

## Operating Loop

v1의 운영 루프는 다음과 같다.

1. 사용자가 요구사항 템플릿 문서를 작성한다.
2. Claude가 상위 계획 문서를 생성한다.
3. Claude가 하위 단계 문서를 생성한다.
4. 사용자가 피드백을 준다.
5. Claude가 즉시 반영하거나, 수정 제안을 만들고 승인 후 반영한다.
6. 변경 후 문서 간 정합성을 다시 확인한다.

## Approach Options Considered

### Option A: 문서 중심 하네스

문서만으로 입력, 출력, 수정 루프를 구성한다.

- 장점: 가장 단순하고 v1 목적에 잘 맞는다.
- 단점: 상태 추적 자동화는 약하다.

### Option B: 문서 + 상태 파일 하네스

문서와 함께 `state.json` 같은 메타 상태를 둔다.

- 장점: 이후 자동화 확장이 쉽다.
- 단점: v1에서는 구조가 무거워진다.

### Option C: 문서 + 명령 워크플로 하네스

문서뿐 아니라 `/plan`, `/revise-step` 같은 명령 인터페이스까지 같이 설계한다.

- 장점: 장기적으로 실제 하네스 느낌이 강하다.
- 단점: 첫 버전 범위를 키운다.

## Recommended Approach

Option A를 채택한다.

다만 Option B의 일부 개념은 문서 frontmatter에 흡수한다. 이렇게 하면 별도 상태 저장 시스템 없이도 단계 의존성과 상태를 다룰 수 있다.

## Risks

- 템플릿이 과도하게 빡빡하면 사람이 쓰기 어려워질 수 있다.
- 템플릿이 느슨하면 계획 품질이 흔들릴 수 있다.
- 상위 계획과 하위 단계 문서의 동기화 규칙이 약하면 문서가 빠르게 어긋날 수 있다.
- 수정 요청 처리 방식이 모호하면 Direct update와 Propose then apply가 섞여 혼란을 줄 수 있다.

## Next Step

다음 단계는 구현이 아니라 계획이다.

구체적으로는 다음을 정의해야 한다.

1. 실험 폴더 초기 구조 생성 계획
2. 템플릿 3종의 필수 섹션 정의
3. 상위 계획 생성 규칙 정의
4. 하위 단계 문서 생성 규칙 정의
5. 수정 요청 처리 규칙 정의

