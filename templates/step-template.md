---
id: step-01
title: example-step
status: draft
depends_on: []
outputs: []
acceptance: []
screen_ids: []
visual_scope: not-applicable
---

# 스텝

## 목표

이 step이 달성하려는 바를 적습니다.

## 범위 안

- 작업 항목 1
- 작업 항목 2

## 범위 밖

- 이 step에서 허용되지 않는 작업 항목

## 시각 범위

- 담당 Screen IDs:
- 이 step이 책임지는 시각 요소:
- 이 step이 책임지지 않는 시각 요소:

`screen_ids` 규칙:

- `docs/visual-analysis/visual-source-analysis.md`가 존재하고 inclusion이 `included`인 모든 screen은 최소 하나의 step에 반드시 할당되어야 한다
- visual 소스가 없는 프로젝트는 `screen_ids: []`, `visual_scope: not-applicable`로 둔다
- `visual_scope` 값: `strict` | `approximate` | `loose` | `not-applicable`

## 산출물

- 산출물 1
- 산출물 2

## 승인 기준

| Criteria | Evidence Type |
| --- | --- |
| Acceptance 1 | test / manual / command / file-check |
| Acceptance 2 | test / manual / command / file-check |

evidence type 설명:
- `test`: 자동화 테스트 실행 로그 (예: vitest, jest)
- `manual`: 브라우저 또는 UI 상호작용 확인
- `command`: CLI 명령 출력 (예: curl, ls, npm run)
- `file-check`: 파일 또는 artifact 존재 확인
