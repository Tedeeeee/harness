---
name: select-technical-approach
description: 제품 요구사항은 계획 시작에 충분하지만, plan generation 전에 구현 접근 방식을 명시적인 기술 결정으로 좁혀서 고정해야 안전하게 계획을 세울 수 있을 때 사용합니다.
---

# 기술 접근 방식 선택

## 개요

이 스킬은 제품 요구를 confirmed technical direction으로 바꿉니다.

상세 계획을 쓰기 전에 implementation approach를 고릅니다.

master plan을 작성하지는 않습니다.

## 사용 시점

- requirements가 계획 시작에 충분할 때
- step planning 전에 프로젝트의 명시적인 technical direction이 여전히 필요할 때
- framework, storage, architecture, testing, deployment choice를 추측으로 넘기게 될 때

이미 confirmed technical approach 문서가 있고 현재 scope와도 여전히 맞는다면 이 스킬을 사용하지 않습니다.

## 먼저 읽을 문서

- `START.md`
- `docs/state-model.md`
- `docs/document-lifecycle.md`
- `docs/requirements/` 아래 최신 파일
- 존재한다면 `docs/interview/development-interview-decisions.md`
- `templates/technical-approach-template.md`

## 핵심 규칙

implementation plan을 쓰기 전에 implementation approach를 먼저 고릅니다.

이 스킬은 기술 옵션을 confirmed decision으로 좁히고, 왜 그 선택을 했는지 기록합니다.

## 절차

1. 현재 requirements 문서를 fixed input으로 읽습니다
2. 기존 interview decision이 있으면 읽습니다
3. planning을 안전하게 만들기 전에 어떤 decision area가 confirmed되어야 하는지 찾습니다:
   - application/runtime framework
   - data storage and schema strategy
   - API or integration shape
   - authentication or access control
   - testing strategy
   - deployment/runtime assumptions
4. 아직 해결되지 않은 decision area 중 가장 우선순위가 높은 하나를 고릅니다
5. trade-off와 recommendation을 곁들여 viable option `2`개 또는 `3`개를 제시합니다
6. 아직 user confirmation이 필요하면 정확히 하나의 질문만 합니다
7. confirmed된 decision만 `docs/architecture/technical-approach.md`에 기록합니다
8. planning이 더 이상 technical guess에 의존하지 않을 때까지 반복합니다

## 종료 조건

아래가 충족될 때만 다음 단계로 handoff할 수 있습니다:

- 주요 implementation approach가 문서화되었을 때
- planning에 필요한 technical choice가 confirmed되었을 때
- 남은 unknown이 planning-critical하지 않을 때

## 즉시 멈추는 경우

다음 경우에는 멈추고 사용자에게 묻습니다:

- product scope가 바뀌어야 할 때
- 추천안이 승인되지 않은 constraint에 의존할 때
- planning-critical decision이 둘 이상 여전히 unresolved일 때
- 명시적 승인 없이 어떤 결정을 final로 기록하려 할 때

## 자동 진행 가능

다음 경우에는 이 스킬 안에서 계속 진행합니다:

- 다음 unresolved item을 하나의 decision question으로 정리할 수 있을 때
- 선택이 product scope가 아니라 implementation direction 안에 머물 때
- confirmed answer 하나가 planning을 풀어줄 때

## 강한 규칙

- 질문은 한 번에 하나만 합니다
- technology decision을 묶어서 묻지 않습니다
- viable choice가 하나뿐인 상황이 아니면 단일 옵션만 제시하지 않습니다
- 명시적 user approval 없이 recommendation을 final로 표시하지 않습니다
- 이 스킬에서 `docs/plans/master-plan.md`를 작성하지 않습니다
- 기술 방향을 추천하면서 scope를 조용히 확장하지 않습니다

## 출력 형태

### 결정이 남아 있는 동안

- 현재 decision area 식별
- `Option 1`, `Option 2`, 필요하면 `Option 3` 제시
- recommendation과 그 이유 설명
- 정확히 하나의 confirmation question

### 완료되었을 때

- `docs/architecture/technical-approach.md` 작성
- planning에 필요한 technical direction이 충분히 confirmed되었다고 명시
- 다음 스킬 이름 제시: `conduct-development-interview`

## 흔한 실수

- technical direction을 고정하지 않고 requirements에서 바로 plan으로 뛰어가는 것
- framework나 storage 추측을 사소한 detail로 취급하는 것
- 한 번에 여러 decision question을 묻는 것
- AI preference를 confirmed decision처럼 기록하는 것
- 기술 추천과 함께 product-scope change를 섞어 넣는 것

## 성공 조건

하네스가 숨겨진 technical assumption에 의존하지 않고 implementation step을 계획할 수 있습니다.
