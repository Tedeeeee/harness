# Parallelism Contract

이 문서는 하네스에서 **어떤 작업이 병렬 실행 안전한가**를 정의한다. 안전한 범위를 벗어나는 병렬화는 이 단계에서 허용하지 않는다.

## 핵심 원칙

- 같은 상태 문서를 **두 에이전트가 동시에 수정**하면 안 된다 (race)
- **분석/조회는 병렬 가능**, **쓰기는 단일 writer 원칙**
- verification 문서는 여러 에이전트가 근거를 만들어도 최종 취합은 한 에이전트가 한다

## Safe (병렬 가능)

- PDF / 프로토타입 screen 인벤토리 추출 (여러 페이지를 병렬로 읽어 후 취합)
- visual diff 생성 (screen 단위로 병렬)
- coverage 체크 (screen inventory ↔ 구현 간 매핑 점검)
- memory 조회 (read-only)
- trace 조회 (read-only)
- test suite 실행 중 기능 검증과 시각 검증을 분리된 runner로 돌리기
- 독립된 acceptance item에 대한 evidence 수집 (서로 다른 파일/URL을 건드리는 경우)

## Unsafe (아직 금지)

- 같은 step의 코드 작성을 두 에이전트가 동시에
- 동일한 state 문서(`implementation-state.md`, `planning-state.md`, requirements, step docs) 동시 수정
- 같은 verification document 동시 작성
- memory 파일 동시 수정 (append도 포함 — retrospective가 single writer)
- trace 파일은 `append_trace`가 append-only지만 동시 append는 줄 깨짐 가능성 — 동일 순간 병렬 trace 기록은 피한다

## 병렬 실행 예시

### 분석 fan-out

`analyze-visual-source`는 screen 수가 많을 때 각 screen 블록을 병렬 분석할 수 있다. 단, 분석 결과를 `visual-source-analysis.md`에 쓰는 작업은 단일 에이전트가 담당한다.

### 기능/시각 검증 분리

`verify-current-step`은 functional pass와 visual pass를 독립 에이전트로 실행할 수 있다. 각자 evidence block을 만들고, step verification document 작성은 단일 writer가 두 결과를 합친다.

## Trace 규칙

병렬 실행 시 trace event 2개를 짝으로 기록한다:

- `parallel-start`: actor는 fan-out을 시작한 주 skill, reason은 병렬 작업 이름, detail은 참여자 수
- `parallel-join`: actor는 동일 주 skill, reason은 병렬 작업 이름, detail은 결과 요약 (pass/fail 수 등)

## 이 계약을 벗어나는 병렬화 요청이 들어올 때

- "구현을 동시에 두 에이전트가" — 거절하고 이 문서로 되돌려준다
- "같은 문서를 동시에 수정" — 거절하고 writer 분리 제안
- 계약을 확장하고 싶다면 `docs/harness-roadmap.md`의 Backlog에 제안을 추가한 뒤 별도 phase로 다룬다
