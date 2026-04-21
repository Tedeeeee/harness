# 하네스 후속 메모

## 목적

이 문서는 다음 작업 세션에서 하네스를 어떤 순서로 보강해야 하는지 빠르게 이어가기 위한 메모다.

## 현재 상태 요약

- `router -> planner -> executor -> verification` 기본 루프는 동작한다.
- runtime hook(`session-start`, `user-prompt-submit`, `stop-guard`)은 실제로 작동한다.
- `memory/` 레이어는 추가되었지만, 아직 행동 변화를 강하게 만들 정도로 활용되지는 않는다.
- `docs/verification/step-xx-verification.md` 문서가 생성되도록 계약을 보강했다.
- generated project는 `experiments/` 아래에 생성되도록 운영 중이다.

## 현재 확인된 약점

### 1. 문서 계약이 아직 완전히 고정되지 않음

- `implementation-state.md`가 상태판 역할만 해야 하는데, 여전히 검증 결과나 예외 메모가 섞일 가능성이 있다.
- step 문서의 `status` 같은 메타데이터가 실행 후에도 정리되지 않는 경우가 있다.
- `confirmed`, `auto default`, `user skip` 같은 결정 상태의 의미가 아직 충분히 분리되지 않았다.

### 2. hook이 상태 문서 포맷에 민감함

- `Blockers`에 `- None` 대신 다른 표현이 들어가면 `stop-guard`가 blocker로 해석할 수 있다.
- 현재 hook은 잘 동작하지만, 문서 형식이 조금만 흔들려도 과민 반응할 수 있다.

### 3. memory가 실제 행동 변화로 아직 충분히 연결되지 않음

- 지금은 memory를 읽는 수준이다.
- planner/router가 memory를 활용해 질문을 줄이거나 기본값을 재사용하는 장면은 아직 약하다.

### 4. requirements 작성 단계가 아직 암묵적임

- 현재는 요구사항이 없을 때 자연스럽게 requirements 초안을 만들고 있지만,
- 별도 `requirements authoring` skill로 명확히 분리되지는 않았다.

### 5. 사용자 인터럽트 상태가 없음

- 작업 도중 사용자가 새 요청을 넣었을 때,
- 이것을 `blocked`로 볼지, 별도 인터럽트 상태로 볼지 아직 정식 설계가 없다.

### 6. 관측성이 부족함

- 어떤 hook이 개입했는지
- 어떤 skill이 왜 선택됐는지
- memory가 실제로 영향을 줬는지
- 나중에 추적하기 어렵다.

## 다음 작업 우선순위

### 우선순위 1. 문서 계약 고정

- `implementation-state.md`는 상태판 역할만 하도록 더 강하게 제한
- step 문서의 `status` 메타데이터 업데이트 규칙 정리
- 인터뷰 문서에서 `confirmed`와 `assumed default` 분리
- `user skip` 또는 `verified-with-skip` 같은 상태 표현 필요 여부 결정

### 우선순위 2. 사용자 인터럽트 처리 모델 추가

추천 방향:

- `blocked`와 별개로 `interrupted_by_user` 상태 추가 검토
- `implementation-state.md`에 `User Interruption` 섹션 추가 검토
- `user-prompt-submit`에서 단순 승인/계속과 실제 인터럽트를 구분
- 새 요청 처리 후 기존 step으로 복귀하는 규칙 정의

### 우선순위 3. memory를 실제 행동 변화로 연결

- planner가 반복 질문을 줄이도록 memory 활용
- blocked 대응 방식에 memory 적용
- project memory를 통해 반복 기술 선택 재사용

### 우선순위 4. observability/log 추가

- 어떤 hook이 실행됐는지
- 어떤 state를 읽었는지
- memory를 사용했는지
- 간단한 로그를 남기는 방식 검토

### 우선순위 5. requirements authoring skill 분리

- requirements가 없을 때의 초안 작성 규칙을 별도 skill로 명시
- 현재 planner 앞단의 암묵 동작을 명문화

## 내일 시작할 때 추천 순서

1. 이 문서를 다시 읽고 현재 우선순위 확인
2. `implementation-state-template.md`와 관련 skill 계약 다시 점검
3. `interrupted_by_user` 상태 모델을 설계할지 결정
4. 가능하면 작은 테스트 프로젝트 하나로 다시 검증

## 내일 바로 확인할 질문

- `blocked`와 `interrupted_by_user`를 분리할 것인가?
- `confirmed`와 `assumed default`를 문서에서 어떻게 구분할 것인가?
- memory 사용 흔적을 어떤 형식으로 남길 것인가?

## 한 줄 정리

지금 하네스는 큰 그림과 기본 루프는 성공했고, 다음 단계는 기능 추가보다 `운영 계약`, `인터럽트 처리`, `memory 활용`, `관측성`을 단단하게 만드는 것이다.

## 보강 closure 기록

### 2026-04-21 — phase-01 (Closure Contract) 완료

- `docs/harness-roadmap.md`에 6-phase 로드맵 수립
- requirements chain에 `Status: draft | assessed | confirmed` + `Confirmed By` + `Linked Planning State` 도입
- `assess-product-requirements`가 승인 시 요구사항/planning-state를 한 트랜잭션으로 동기화
- `implementation-state`와 `planning-state`에 closure 규칙 명시 (`Current Step=none`, `Planning Final Status=closed`, Visual Pass 슬롯 예약)
- `verify-current-step`에 마지막 step pass 시 두 state 전환 절차 추가
- `project-retrospective` 진입 조건 5개로 고정
- `hooklib.detect_closure_mismatch` + `stop_guard` 연결 + 4+1 테스트 추가 (전 10개 pass)

### 2026-04-21 — phase-02 (Visual Fidelity Verification) 완료

- `visual-source-analysis-template`와 `analyze-visual-source`에 `V-NN` screen ID 체계 도입 (재사용 금지)
- `step-template`에 `screen_ids` + `visual_scope` frontmatter, "시각 범위" 섹션 추가
- `generate-step-docs`에 visual 할당 규칙: included screen 누락 시 blocker
- `step-verification-template`에 "시각 검증" 섹션 (대상 screen IDs, 6 카테고리 표, 증거)
- `templates/visual-fidelity-checklist-template.md` 신설 (coverage/spacing/hierarchy/tab bar/banner/typography)
- `verify-current-step`에 Visual Pass 절차 추가: screen_ids 일치, visual_scope 엄격도 적용, `Last Verification Result.Visual Pass` 전환
- closure 전환 조건에 "모든 completed step에 시각 검증 증거" 추가

### 2026-04-21 — phase-01 실전 검증 evidence

phase-03 완료 직후 `stop_guard`가 이 저장소 자체의 closure mismatch를 실시간으로 잡음:

- `implementation-state.Current Status = done`인데 `Current Step = step-07` 잔존
- `requirements/moyza-discovery-app.md`는 prose로 "Draft"라 적혀 있었으나 planning-state notes에는 "사용자 confirm 받음"으로 기록되어 있었음 (phase-01이 없었다면 조용히 넘어갔을 drift)

조치:
- requirements를 신규 Metadata 포맷으로 전환 (`Status: confirmed`, `Confirmed By`, `Confirmed At`, `Linked Planning State`)
- planning-state에 Closure 섹션 추가 (`Requirements Confirmed: yes`, `Planning Final Status: closed`, `Retrospective: not-started`)
- implementation-state의 `Current Step`을 `none`으로, `Next Allowed Action`을 `start-retrospective`로, `Visual Pass: n/a` 슬롯 추가

결론: detector가 의도대로 동작. phase-01의 가치 증명.

### 2026-04-21 — phase-03 (Observability / Trace) 완료

- `templates/trace-entry-template.md` 신설: `- TIMESTAMP [event_type] actor — reason | detail` 한 줄 포맷, event_type 9종 정의
- `docs/trace/README.md`로 목적과 읽는 법 문서화 (증거 아님, 디버깅용)
- `hooklib.append_trace(event_type, actor, reason, detail=None)` 추가, 날짜별 파일에 append-only, OSError는 silent swallow
- 3 hook(session-start, user-prompt-submit, stop-guard)이 진입 시 trace 기록, stop-guard는 block 여부 같이 기록
- `route-self-harness`가 선택 이유를 `skill-selected`로 기록
- `implementation-blocker`가 분류를 `blocker`로 기록
- `verify-current-step`이 `visual-pass`와 `closure`를 기록
- hooklib 테스트 13개 전부 pass (기존 10 + 신규 3: trace 생성/append/unknown event)

### 2026-04-21 — phase-04 (Memory Activation) 완료

- `memory/harness-memory.md`, `memory/project-memory.md`에 카테고리 범례(`user | feedback | project | reference`) + 섹션 태그 추가 (내용 보존)
- `project-retrospective`에 "Memory Candidate Review" 단계 + trace 기반 3회 반복 트리거 + 사용자 승인 후에만 승격 + `memory-promoted` trace 기록
- `route-self-harness`, `conduct-development-interview`, `generate-master-plan`에 memory 조회 절차와 `memory-read` trace 기록 규칙 추가
- interview의 default 옵션에 `(from memory)` 라벨 도입, 뒤집힐 경우 interview notes에 기록
- `generate-step-docs`에 `visual_scope` 기본값이 project-memory에서 오도록 규칙 추가

### 2026-04-21 — phase-05 (User Interrupt Model) 완료

- `implementation-state-template`에 `interrupted_by_user` 상태 추가 + `User Interruption` 섹션 (Active/Original Step/Status/Request Summary/Handling Status/Resume Target Step)
- `hooklib.detect_interrupt` 추가: 명시적 "잠깐/먼저/wait/pause" 키워드 + 단순 continuation 우선 규칙 + 활성 상태가 아닐 때 never-fire
- `user_prompt_submit.py`가 interrupt 감지 시 additionalContext로 상태 전환 절차 주입 + trace 기록
- `implement-current-step`에 Interrupt 처리 분기 (boundary 안이면 handled → 복귀, 밖이면 merged → implementation-blocker)
- `route-self-harness`에 `interrupted_by_user` → `implement-current-step` 라우팅 추가
- hooklib 테스트 17개 전부 pass (기존 13 + interrupt 4)

### 2026-04-21 — phase-06 (Safe Multi-Agent) 완료

- `docs/parallelism-contract.md` 신설: safe/unsafe 명확 분류, 분석 fan-out 예시, 기능/시각 검증 분리 예시, single-writer 원칙
- `analyze-visual-source`에 screen 단위 병렬 분석 옵션 (단일 writer로 병합)
- `verify-current-step`에 functional/visual 병렬 실행 옵션 (단일 writer로 verification doc 통합)
- 병렬 trace event(`parallel-start`/`parallel-join`)는 phase-03에서 이미 정의됨, 이번 phase에서 사용처 문서화

### 2026-04-21 — 로드맵 6 phase 전체 완료

- 시작 시 식별된 약점(visual pass 부재, closure 동기화 깨짐, 관측성 없음, memory 미활용, interrupt 모델 부재, 병렬화 계약 없음) 전부 보강
- `hooks/test_hooklib.py` 17/17 pass
- 실전 검증: phase-03 완료 직후 closure detector가 저장소 자체의 drift(움직이지 않은 `Current Step`, prose Draft로 남아 있던 requirements)를 정확히 잡아 retrofit 유도 — 로드맵의 가치 증명
