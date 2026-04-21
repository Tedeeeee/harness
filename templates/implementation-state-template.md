# Implementation State

## Summary

- Current Step:
- Current Status: in_progress | verification-ready | blocked | interrupted_by_user | done
- Last Updated:

Rule:

- `Current Status = done`이면 `Current Step`은 반드시 `none`이다
- 모든 step이 `completed`여야 `Current Status`를 `done`으로 전환할 수 있다
- `done` 진입 시 `Next Allowed Action`은 `start-retrospective`로 고정된다
- `interrupted_by_user`는 사용자의 새 요청이 현재 step scope를 벗어날 때 자동 또는 수동으로 전환된다. 처리 후 원래 step으로 복귀한다. 자세한 규칙은 아래 `User Interruption` 섹션 참조.

## Step Status

| Step | Title | Status | Verification Doc | Notes |
| --- | --- | --- | --- | --- |
| step-01 |  | pending |  |  |

Step status values:

- `pending`
- `in_progress`
- `completed`
- `blocked`

## Active Step Scope

- In Scope:
- Out of Scope:
- Acceptance Focus:

## User Interruption

- Active: no | yes
- Started At:
- Original Step:
- Original Status:
- Request Summary:
- Handling Status: pending | handled | merged
- Resume Target Step:

Rule:

- `Active: yes`일 때만 다른 필드가 의미를 가진다
- interrupt 처리 이후 원래 step으로 복귀하면 이 섹션 전체를 기본값(`Active: no`, 나머지 비움)으로 되돌린다
- 한 번에 하나의 interrupt만 활성화된다 (중첩 금지)

## Blockers

- None

Rule:

- use exactly `- None` when no blocker exists
- otherwise list blocker items as bullets

## Last Verification Result

- Step:
- Result: not-run | pass | fail | blocked
- Visual Pass: n/a
- Verification Doc:
- Notes:

Rule:

- `Visual Pass` 슬롯은 phase-01에서 예약된 자리이다. visual-source 프로젝트가 아니면 기본값 `n/a`로 둔다.
- phase-02가 visual-source 프로젝트에서 `not-run | pass | fail` 전환 규칙을 부여한다.

## Next Allowed Action

- Start the current step
