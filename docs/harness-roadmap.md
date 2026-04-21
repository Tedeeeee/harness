# 하네스 강화 로드맵

## 목적

이 문서는 하네스를 단계적으로 보강하기 위한 **실행 단위 설계서**다. 각 phase는 목표, 바꿀 파일, 작업 항목, 완료 기준을 갖추어 그 자체로 착수 가능하게 쓴다.

`docs/follow-up-notes.md`는 세션 메모로 남기고, 이 문서가 보강 작업의 source of truth다.

## 전제

- 기본 루프(`router → planner → executor → verification`)는 이미 동작한다
- `experiments/` 아래 실제 프로젝트로 검증한다
- 각 phase는 앞 phase에 의존할 수 있으므로 순서대로 닫는다
- phase 자체 착수 시에는 하네스 정식 플로우(requirements → plan)를 타지 않고, 이 문서의 작업 항목을 직접 실행한 뒤 **follow-up-notes에 closure 기록**을 남기는 것으로 대체한다

## 순서

1. Closure Contract
2. Visual Fidelity Verification
3. Observability / Trace
4. Memory Activation
5. User Interrupt Model
6. Safe Multi-Agent

> 순서 설명: 지금 하네스의 가장 흔한 실제 실패는 `requirements confirmed ↔ planning-state ↔ Current Step ↔ retrospective` 간 동기화가 어긋나는 것이다. 이걸 먼저 잡지 않으면 visual pass, trace, memory 같은 이후 phase가 다 흔들리는 토대 위에 쌓인다. 그래서 closure를 맨 앞에 둔다. 대신 closure는 "Visual Pass 슬롯"을 미리 비워두어 phase-02가 채워 넣도록 설계한다.

---

## Phase 1. Closure Contract

- id: phase-01
- depends_on: []
- status: done
- completed_at: 2026-04-21

### 목표

프로젝트가 "done"에 도달하는 **계약을 명시**하고, `requirements → planning-state → implementation-state → retrospective` 간 상태가 자동으로 동기화되도록 만든다. 이후 phase(visual pass, trace, memory 등)가 얹힐 수 있게 **Visual Pass 슬롯을 미리 비워둔다.**

### 범위 안

- requirements confirmed 상태 정의와 planning-state 동기화
- `Current Status = done`일 때 `Current Step` 자동 정리 규칙
- `planning-state`에 최종 종료 상태(closed) 추가
- retrospective 진입 조건 고정
- `stop_guard`가 "미완결 closure"를 감지
- `Last Verification Result`에 `Visual Pass` 슬롯 예약 (phase-02가 채움)

### 범위 밖

- 프로젝트 archive 자동화
- multi-project 상태 관리
- visual pass 자체의 검증 규칙 (phase-02)

### 바꿀 파일

- `templates/implementation-state-template.md`
- `templates/planning-state-template.md`
- `templates/product-requirements-template.md`
- `skills/author-product-requirements/SKILL.md`
- `skills/assess-product-requirements/SKILL.md`
- `skills/verify-current-step/SKILL.md`
- `skills/project-retrospective/SKILL.md`
- `hooks/hooklib.py`
- `hooks/stop_guard.py`
- `hooks/test_hooklib.py`

### 작업 항목

1. `product-requirements-template.md` 헤더에 closure 관련 필드 표준화:
   - `Status: draft | assessed | confirmed`
   - `Confirmed By:` (사용자 승인 시각/주체)
   - `Linked Planning State:` (상대 경로)
2. `author-product-requirements` SKILL에 규칙 추가:
   - 생성 시 `Status: draft` 고정
   - planning-state 경로 링크 필수
3. `assess-product-requirements` SKILL에 규칙 추가:
   - 사용자 승인 시 `Status: confirmed`로 전환
   - 같은 트랜잭션에서 planning-state의 `Requirements Confirmed: yes`로 동기화
   - 둘 중 하나라도 못 바꾸면 assessed에서 멈춤
4. `planning-state-template.md`에 "Closure" 섹션 추가:
   - `Requirements Confirmed: yes | no | n/a`
   - `Planning Final Status: not-closed | closed`
   - `Retrospective: not-started | complete`
5. `implementation-state-template.md` 규칙 강화:
   - `Current Status = done`이면 `Current Step`은 반드시 비워두거나 `none`
   - 모든 step이 `completed`여야 `done` 진입 가능
   - done 이후에는 `Next Allowed Action = start-retrospective` 고정
   - `Last Verification Result`에 `Visual Pass: not-run | pass | fail | n/a` 슬롯 예약 (이번 phase에서는 기본값 `n/a` 고정, phase-02에서 동작 부여)
6. `verify-current-step`에 closure 분기 추가:
   - 마지막 step pass 시 implementation-state를 `done`으로 전환하고 `Current Step`을 비움
   - planning-state도 동시에 `Planning Final Status = closed`로 전환
7. `project-retrospective` SKILL 전제 조건 고정:
   - `implementation-state.Current Status = done`
   - `planning-state.Planning Final Status = closed`
   - `planning-state.Requirements Confirmed = yes`
   - 하나라도 어긋나면 시작 거부
8. `hooklib.py`에 `detect_closure_mismatch(summary, planning, requirements)` 추가:
   - done인데 Current Step이 있음
   - 모든 step completed인데 Current Status != done
   - planning-state closed가 아닌데 implementation done
   - requirements Status=confirmed인데 planning-state Requirements Confirmed=no
   - → `stop_guard`가 blocker로 보고
9. `stop_guard.py`에 closure mismatch를 blocker로 연결
10. `test_hooklib.py`에 mismatch 케이스 4종 테스트 추가

### 승인 기준

| Criteria | Evidence Type |
| --- | --- |
| requirements confirmed 이후 planning-state가 동기화되지 않으면 stop_guard가 차단한다 | test (hooks/test_hooklib.py) |
| done일 때 Current Step이 남아 있으면 stop_guard가 차단한다 | test |
| 마지막 step pass 시 implementation-state와 planning-state가 같은 트랜잭션에서 closure로 전환된다 | manual (experiment 하나로 재현) |
| retrospective는 closure/requirements-confirmed 중 하나라도 어긋나면 시작 거부한다 | manual |
| `Last Verification Result.Visual Pass` 슬롯이 템플릿에 존재하고 기본값 `n/a`로 동작한다 | file-check |

---

## Phase 2. Visual Fidelity Verification

- id: phase-02
- depends_on: [phase-01]
- status: done
- completed_at: 2026-04-21

### 목표

PDF/프로토타입/와이어프레임이 source of truth인 프로젝트에서, **functional pass와 visual pass를 분리**하고, 화면 inventory 기준 coverage를 closure 신호에 포함시킨다. 이를 위해 **step과 screen inventory를 문서 레벨에서 연결**한다 (verifier가 추론하지 않도록).

### 범위 안

- step 문서에 담당 screen ID 필드 추가 (verifier가 덜 추론)
- `verify-current-step`에 visual pass 분기
- `step-verification-template.md`에 visual fidelity 섹션 고정
- `visual-source-analysis.md`의 screen inventory와 verification 간 매핑 규칙
- visual 체크리스트 카테고리 표준화: coverage / spacing / hierarchy / tab bar / banner / typography
- phase-01에서 예약한 `Visual Pass` 슬롯에 실제 동작 부여

### 범위 밖

- 자동 screenshot diff 도구 도입
- 픽셀 단위 비교
- visual source가 없는 프로젝트의 동작 변경 (functional pass만으로 닫힘)

### 바꿀 파일

- `templates/step-template.md` — `Screen IDs` / `Visual Scope` 필드 추가
- `skills/generate-step-docs/SKILL.md` — 위 필드를 채우는 절차 추가
- `templates/step-verification-template.md` — "Visual Fidelity" 섹션 추가
- `templates/implementation-state-template.md` — phase-01에서 예약한 `Visual Pass`에 동작 부여
- `skills/verify-current-step/SKILL.md` — visual 분기 절차와 "pass 금지" 규칙
- `skills/analyze-visual-source/SKILL.md` — screen inventory 출력 계약 보강 (verification ID 부여)
- `templates/visual-source-analysis-template.md` — screen ID 필드 강제 (ex. `V-01`)
- (신규) `templates/visual-fidelity-checklist-template.md`

### 작업 항목

1. `analyze-visual-source` 출력에 screen ID 부여 규칙 추가 (예: `V-01`, `V-02`). 각 screen에 `id`, `name`, `inclusion`, `mandatory directives` 필수.
2. `step-template.md`에 다음 필드 추가:
   - `screen_ids: [V-01, V-02]` (frontmatter)
   - `visual_scope: strict | approximate | not-applicable`
   - 본문에 `## 시각 범위` 섹션 — 어떤 screen ID를 이 step이 구현하는지, 어떤 시각 요소를 책임지는지
3. `generate-step-docs` SKILL에:
   - visual-source-analysis.md가 존재하면 각 step에 최소 하나 이상의 screen ID 할당
   - screen inventory의 모든 in-scope 화면이 어떤 step에 반드시 들어가야 함 (누락 시 blocker)
4. `step-verification-template.md`에 `## 시각 검증` 섹션 추가:
   - 적용 여부(yes/no/not-applicable)
   - 대상 screen ID 목록 (step 문서의 `screen_ids`와 일치해야 함)
   - 카테고리별 결과 표 (6개)
   - 증거(스크린샷 경로 또는 수동 관찰 노트)
5. `visual-fidelity-checklist-template.md` 신설: coverage / spacing / hierarchy / tab bar / banner / typography 6개 카테고리, 각 카테고리당 expected / observed / result
6. `verify-current-step` SKILL에 규칙 추가:
   - 프로젝트에 `docs/visual-analysis/visual-source-analysis.md`가 존재하면 visual pass는 필수
   - step의 `screen_ids`에 등장한 화면은 체크리스트에 전부 등장해야 함
   - visual pass가 없거나 fail이면 step을 completed로 표시하지 않음
   - pass 시 `implementation-state.Last Verification Result.Visual Pass`를 `pass`로 전환
7. closure 조건 확장 (phase-01의 retrospective 전제 조건에 추가):
   - visual-source 프로젝트인 경우 모든 completed step에 visual pass 증거가 있어야 retrospective 진입 허용

### 승인 기준

| Criteria | Evidence Type |
| --- | --- |
| visual-source 프로젝트에서 step 검증 시 Visual Fidelity 섹션이 채워지지 않으면 verifier가 pass를 내지 않는다 | manual |
| step 문서의 `screen_ids`와 verification의 대상 screen ID 목록이 일치한다 | file-check |
| screen inventory의 in-scope 화면이 어느 step에도 할당되지 않으면 `generate-step-docs`가 blocker를 낸다 | manual |
| visual source가 없는 프로젝트는 기존 flow 그대로 동작한다 | manual |
| `implementation-state.Visual Pass` 슬롯이 phase-01에서 예약된 자리 그대로 동작한다 | file-check |

---

## Phase 3. Observability / Trace

- id: phase-03
- depends_on: [phase-01]
- status: done
- completed_at: 2026-04-21

### 목표

**왜 이 skill이 선택됐는지 / 어떤 hook이 개입했는지 / memory가 어떻게 반영됐는지 / blocker 이유가 무엇이었는지**를 짧은 trace로 남긴다.

> phase-02와 병렬 착수 가능. trace 포맷이 phase-02의 visual pass 이벤트까지 포함하도록 설계하지만, 선착수한 쪽이 이벤트 타입을 추가하는 식으로 merge 한다.

### 범위 안

- 세션 단위 trace 로그 파일
- hook 실행 기록
- skill 선택 이유 기록
- memory 참조 기록
- blocker 발생 이유 기록
- closure / visual-pass 이벤트 기록
- trace 조회 방법 문서화

### 범위 밖

- 실시간 대시보드
- 분산 tracing

### 바꿀 파일

- (신규) `docs/trace/` 디렉터리 — 세션별 `trace-YYYY-MM-DD.md`
- (신규) `templates/trace-entry-template.md`
- `hooks/hooklib.py` — `append_trace(event_type, actor, reason, detail)` 추가
- `hooks/session_start.py`, `user_prompt_submit.py`, `stop_guard.py`
- `skills/route-self-harness/SKILL.md`
- `skills/implementation-blocker/SKILL.md`
- `skills/verify-current-step/SKILL.md` — closure / visual-pass 이벤트 로깅

### 작업 항목

1. trace entry 포맷 고정 (timestamp, event_type, actor, reason, detail)
   - event_type: `hook` / `skill-selected` / `memory-read` / `memory-promoted` / `blocker` / `closure` / `visual-pass`
2. `hooklib.append_trace()` 구현 — 같은 날짜 파일에 append-only
3. 각 hook이 자신의 진입/결정을 한 줄 기록
4. `route-self-harness`에 "선택한 skill과 그 이유를 trace에 기록" 절차 추가
5. `implementation-blocker`에 "분류와 근거를 trace에 기록" 절차 추가
6. `verify-current-step`의 closure 전환과 visual pass 결과를 trace에 기록
7. `docs/trace/README.md`에 trace 읽는 법과 event_type 목록 기록

### 승인 기준

| Criteria | Evidence Type |
| --- | --- |
| 세션 한 번 돌리면 `docs/trace/trace-YYYY-MM-DD.md`에 hook 진입 기록이 남는다 | file-check |
| 임의의 skill 선택 시 이유가 trace에 한 줄로 남는다 | file-check |
| blocker 분류가 trace에 남는다 | file-check |
| closure 전환과 visual pass 결과가 trace에 남는다 | file-check |
| trace entry format이 `templates/trace-entry-template.md`와 일치한다 | file-check |

---

## Phase 4. Memory Activation

- id: phase-04
- depends_on: [phase-03]
- status: done
- completed_at: 2026-04-21

### 목표

memory를 "있기만 한" 상태에서 **실제 행동 변화를 만드는 층**으로 끌어올린다. trace가 있어야 "어떤 패턴이 반복됐는지"를 식별할 수 있으므로 phase-03 이후에 둔다.

### 범위 안

- 반복 결정 자동 승격 규칙
- visual fidelity 선호 수준 기억 (phase-02 `visual_scope` 기본값과 연결)
- 질문 방식 / 승인 방식 / 범위 처리 습관 기억
- planner/router가 memory를 조회해 질문을 줄이는 절차
- retrospective에서 memory 후보 제안

### 범위 밖

- 자동 학습 알고리즘
- cross-user memory 공유

### 바꿀 파일

- `memory/harness-memory.md`
- `memory/project-memory.md`
- `skills/project-retrospective/SKILL.md`
- `skills/route-self-harness/SKILL.md`
- `skills/conduct-development-interview/SKILL.md`
- `skills/generate-master-plan/SKILL.md`

### 작업 항목

1. memory 카테고리 표준화: `user`, `feedback`, `project`, `reference` 구조를 문서에 명시
2. 승격 트리거 규칙:
   - 같은 결정이 trace에 3회 이상 나타나면 retrospective가 후보로 제안
   - 사용자 명시 요청은 즉시 승격
3. `project-retrospective`에 "Memory Candidate Review" 단계:
   - trace에서 반복 결정 추출
   - 사용자 승인 후 memory에 기록
   - 승격 기록을 trace에 `memory-promoted`로 남김
4. `conduct-development-interview` 진입 시 관련 memory 로드 → "default 제안"으로 활용, 사용자가 거부하면 기록
5. visual fidelity 수준 선호(strict / approximate / loose) memory 슬롯 추가 — phase-02의 `visual_scope` 기본값으로 연결

### 승인 기준

| Criteria | Evidence Type |
| --- | --- |
| retrospective 종료 후 승격된 memory가 trace의 `memory-promoted` 이벤트와 일치한다 | file-check |
| interview에서 memory 기반 default 제안이 기록된다 | manual |
| 같은 사용자와 두 번째 프로젝트 시 반복 질문이 줄어든다 | manual (experiment 2개 비교) |

---

## Phase 5. User Interrupt Model

- id: phase-05
- depends_on: [phase-03]
- status: done
- completed_at: 2026-04-21

### 목표

작업 중간 사용자 입력을 **blocked가 아닌 별도 interrupt 상태**로 분리하고, 처리 후 원래 step으로 복귀하는 계약을 명문화한다.

### 범위 안

- `interrupted_by_user` 상태
- interrupt 기록 포맷
- resume 규칙
- `user_prompt_submit` hook의 interrupt 감지
- 단순 승인/계속 vs 실제 interrupt 구분

### 범위 밖

- 자연어 의도 분류 모델 도입

### 바꿀 파일

- `templates/implementation-state-template.md`
- `hooks/user_prompt_submit.py`
- `hooks/hooklib.py`
- `skills/implement-current-step/SKILL.md`
- `skills/route-self-harness/SKILL.md`

### 작업 항목

1. `Current Status` enum 확장: `in_progress | verification-ready | blocked | interrupted_by_user | done`
2. `User Interruption` 섹션: 시간, 원래 step, 새 요청 요약, 처리 상태(pending / handled / merged), resume 대상 step
3. interrupt 감지 규칙 초안: 새 요청이 현재 step scope를 벗어나는 토픽이거나 명시적 "잠깐" / "먼저" 키워드 포함
4. interrupt가 감지되면 `user_prompt_submit` hook이 state를 `interrupted_by_user`로 전환하고 trace에 기록
5. resume 계약: 새 요청 처리 완료 시 사용자 확인 후 원래 step으로 상태 복귀
6. 새 요청이 scope 변경이면 `change-request` 경로로 분기 (Backlog의 후보 skill로 이동)

### 승인 기준

| Criteria | Evidence Type |
| --- | --- |
| 작업 중 새 요청 들어왔을 때 state가 interrupted_by_user로 전환된다 | manual |
| interrupt 처리 후 원래 step으로 복귀하는 로그가 trace에 남는다 | file-check |
| 단순 "계속 진행" 같은 승인은 interrupt로 잡히지 않는다 | manual |

---

## Phase 6. Safe Multi-Agent

- id: phase-06
- depends_on: [phase-01, phase-03]
- status: done
- completed_at: 2026-04-21

### 목표

**상태 문서 공유 충돌이 없는 작업만** 병렬화한다. 같은 문서를 동시에 쓰는 구현 병렬은 이번 phase에서 하지 않는다.

### 범위 안

- 분석 병렬: PDF 해석 / coverage 체크 / visual diff 체크
- 검증 병렬: 기능 검증 / 시각 검증 분리 실행
- 병렬 실행 시 trace 기록 규칙
- 안전한 병렬 작업 목록 문서화

### 범위 밖

- 구현 병렬
- 같은 step verification의 병렬 실행

### 바꿀 파일

- (신규) `docs/parallelism-contract.md`
- `skills/analyze-visual-source/SKILL.md`
- `skills/verify-current-step/SKILL.md`
- `hooks/hooklib.py`

### 작업 항목

1. `parallelism-contract.md`에 safe / unsafe 분류:
   - safe: PDF screen 추출, visual diff 생성, coverage 체크, memory 조회
   - unsafe: 같은 step 코드 작성, 같은 state 문서 수정
2. `verify-current-step`에 functional / visual을 독립 에이전트로 실행 가능하다는 절차 추가 (단, verification document 통합은 단일 writer 원칙 유지)
3. `analyze-visual-source`에서 screen 수가 많을 때 fan-out 분석 허용
4. trace event_type에 `parallel-start` / `parallel-join` 추가

### 승인 기준

| Criteria | Evidence Type |
| --- | --- |
| parallelism-contract 문서에 safe/unsafe 예시가 각각 최소 3개 있다 | file-check |
| verification에서 functional/visual을 병렬로 돌려도 verification document는 하나로 수렴한다 | manual |
| 병렬 실행 이벤트가 trace에 `parallel-start`/`parallel-join`으로 기록된다 | file-check |

---

## 공통 규칙

- 각 phase 착수 전에 이 문서의 해당 phase 섹션을 다시 읽는다
- 완료 시 이 문서 phase 헤더에 `status: done`과 완료 일자를 기록한다
- 각 phase 종료 시 `docs/follow-up-notes.md`에 한두 줄 closure 메모를 남긴다
- phase 중 새 작업이 발견되면 해당 phase "범위 밖"에 추가하고 별도 phase 후보로 이 문서 하단 "Backlog" 섹션에 모은다

## Backlog

- change-request skill (phase-05에서 분기 가능성 식별됨)
- retrospective → memory 자동 승격 규칙 강화 (phase-04의 발전형)
- risk/debt ledger
- self-diagnostic skill (문서 간 불일치 자동 점검)
- 자동 screenshot diff (phase-02의 강화형)
