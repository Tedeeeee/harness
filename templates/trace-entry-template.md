# Trace Entry Template

trace 파일은 `docs/trace/trace-YYYY-MM-DD.md` 경로에 저장된다.

## 파일 헤더 (파일 없을 때 최초 1회)

```
# Trace — YYYY-MM-DD

형식: `- TIMESTAMP [event_type] actor — reason | detail`
```

## 엔트리 포맷

각 엔트리는 한 줄이며 bullet으로 시작한다. 포맷:

```
- 2026-04-21T10:23:00 [event_type] actor — reason | detail
```

- `TIMESTAMP`: ISO 8601 local time, 초 단위
- `event_type`: 아래 enum 중 하나
- `actor`: hook 이름 또는 skill 이름 (예: `session-start`, `route-self-harness`, `verify-current-step`)
- `reason`: 한 줄 요약 (왜 이 이벤트가 발생했는가)
- `detail`: 선택. 추가 맥락 (screen IDs, step id, blocker 분류, 승격된 memory key 등). 생략 가능

## event_type enum

| event_type | 언제 기록하나 |
| --- | --- |
| `hook` | session-start / user-prompt-submit / stop-guard 진입 시점 |
| `skill-selected` | router 또는 다른 skill이 다음 skill을 선택한 순간 |
| `memory-read` | skill이 memory를 조회했을 때 |
| `memory-promoted` | retrospective가 memory에 새 entry를 추가했을 때 |
| `blocker` | implementation-blocker가 blocker를 분류했을 때 |
| `closure` | implementation-state와 planning-state를 done/closed로 전환한 순간 |
| `visual-pass` | visual pass 결과가 확정된 순간 |
| `parallel-start` | 병렬 실행을 시작한 순간 (phase-06) |
| `parallel-join` | 병렬 실행 결과를 합친 순간 (phase-06) |

## 규칙

- append-only. 기존 엔트리를 수정하거나 삭제하지 않는다
- 하루 안에 여러 세션이 있어도 같은 파일에 이어 쓴다
- trace 파일은 verification 증거가 아니다. 운영 디버깅용 로그이다
