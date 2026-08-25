# Personal Orchestration Harness

개인 프로젝트에 붙여 사용하는 AI 개발 오케스트레이션 하네스다. Codex와 Claude가 같은 개발 흐름을 따르도록 만들고, Orca를 실행 런타임으로 사용한다.

핵심 원칙은 간단하다.

- Orca는 실행한다.
- Harness Core는 순서와 규칙을 통제한다.
- 사용자는 중요한 결정을 승인한다.
- 프로젝트는 기능의 현재 동작을 문서로 소유한다.

## 전체 흐름

    아무 Claude/Codex 세션에서 사용자 요청
      ↓
    세션이 Harness Bootstrap 자동 실행
      ├─ 기능명·Feature ID 생성
      ├─ orch/<feature-id> Branch
      └─ 하나의 파생 Worktree
          ↓
        Orca Feature Run
          ↓
        Feature Agent             Claude Opus 5
          ├─ 요구사항 Skill
          ├─ 설계 Skill
          ├─ 구현 Skill
          ├─ 검증 Skill
          └─ 통합 Skill
               ↓
             통합·충돌 검토
               ↓ 사용자 merge 승인
             기준 브랜치에 merge
               ↓ 별도 승인
             push / PR

하나의 기능은 하나의 AI, 하나의 Orca Run, 하나의 Feature Task, 하나의 파생 Worktree, 하나의 사용자 대화를 사용한다. 단계가 바뀌어도 Agent와 Worktree를 바꾸지 않고 Skill과 상태만 바꾼다. 기준 브랜치는 실행 중 직접 수정하지 않는다. Feature Agent가 요구사항·설계 결과와 질문을 자기 채팅으로 직접 보여주고, 사용자의 답변을 같은 세션에서 받는다.

## 사용자 요청 방식

사용자는 어떤 모델을 쓸지, 어떤 Worktree를 만들지, 작업 절차가 무엇인지 프롬프트에 넣지 않는다. Claude인지 Codex인지 알 수 없는 일반 세션에서 시작해도 된다. 첫 기능 수정·추가 요청이 들어오면 해당 세션이 현재 브랜치를 기준으로 live Harness Bootstrap을 자동 실행하고, 사용자는 문제·목표·원하는 동작·알고 있는 근거만 전달하면 된다.

Bootstrap이 성공하기 전에는 제품 파일을 읽거나 테스트·DB·프로젝트 명령을 실행하지 않는다. 현재 브랜치가 dirty해도 기존 변경을 건드리지 않고 현재 브랜치의 HEAD에서 child Worktree를 만든다. 기존 변경은 base 폴더에 보존하고 child에는 포함하지 않는다. 이미 Feature Run에 바인딩된 세션이면 새 Worktree를 만들지 않고 기존 Run을 이어간다.

예:

    의뢰인 이름 중복과 빈 이름 문제가 있어. 확인하고 필요한 수준으로 개선해줘.

Harness Bootstrap이 기능 ID·Branch·Worktree·Orca Run·Feature Task·Feature Agent를 만들고, Feature Agent가 현재 단계에 필요한 Skill·질문·승인 gate를 결정한다. 사용자가 `분석만 해줘`, 특정 모델, 특정 agent를 매번 지정하거나 Claude/Codex를 직접 열 필요는 없다.

사용자가 제시한 구현 방법은 확정 설계가 아니라 검증할 가설로 취급한다. 오케스트레이터는 요구사항 분석 결과를 먼저 설명하고, 데이터·권한·계약·아키텍처·migration처럼 중요한 결정 앞에서는 자동으로 멈춰 사용자의 승인을 받는다. 승인 전 구현은 시작하지 않는다.

`fast`도 사용자가 매번 입력해야 하는 실행 선택이 아니다. 기본값은 Fast 미사용이다. 빠른 실행이 필요한 경우에만 원래 기능 요청에 독립 토큰 `fast`를 넣는다. Bootstrap이 이 선택을 Feature Run 전체에 고정하고, Fast를 지원한다고 선언한 route에만 적용한다. 지원하지 않는 route는 자동 대체하지 않고 Coordinator가 보고하고 묻는다.

사용자가 명시적으로 설명·조사·리뷰만 요청한 경우에는 해당 결과에서 멈춘다. 그 외의 기능 개발과 버그 수정은 Feature Run의 기본 순서를 따른다.

오케스트레이터는 단계 이름을 사용자에게 매번 입력받지 않지만, 내부 상태 gate는 생략하지 않는다. 요구사항 확인은 설계 단계로 넘어갈 수 있게 할 뿐이고, 설계 승인은 그 설계·범위·비목표에 한해서만 구현을 열어 준다. `계속`, `진행해줘` 같은 일반적인 이어가기 표현은 구현 승인으로 해석하지 않는다. 구현 전에 Orca Run·Task와 `validate-feature-transition.ps1` 검증이 모두 필요하다.

## 설치 방식

개인용으로 사용할 때는 external-global 모드를 기본으로 한다. 하네스 원본은 `C:\study\harness`에 두고, 다음 스크립트가 Core·rules·templates·adapters·scripts와 선택적 개인 Skill을 사용자 전역 폴더에 설치한다.

    powershell -File scripts\sync-global-harness.ps1

이 모드에서는 대상 프로젝트에 `.harness`나 개인 Skill·개인 진입 브리지를 만들지 않는다. 프로젝트에는 제품 코드와 프로젝트 고유 규칙만 남는다. `personal-harness/config.json`이 없거나 비활성화된 컴퓨터에서는 개인 오케스트레이션을 건너뛰고 프로젝트의 `AGENTS.md`, `CLAUDE.md`, 기본 Skill만 사용한다. `sync-project-overlay.ps1`은 팀 전체가 명시적으로 공유할 때만 사용하는 별도 배포 모드이며, 개인 `personal-orchestration` Skill이나 개인 entrypoint를 프로젝트에 복사하지 않는다.

external-global 설치는 Claude의 전역 설정에 개인 prompt hook을 등록하지 않는다. Claude와 Codex는 전역 instruction bridge와 native Skill을 통해 같은 Bootstrap 규칙을 읽는다. 기존에 설치된 개인 hook이 있으면 동기화 과정에서 제거하고, Orca가 소유한 기존 런타임 hook은 건드리지 않는다.

## 책임 분리

### Orca

Orca는 버전에 맞는 orchestration runtime의 원본이다.

- Run과 Feature Task
- Feature Agent terminal
- 내부 에이전트·런타임 coordination용 ask/reply
- 사용자 decision gate
- provider fallback과 escalation
- runtime 재개와 상태 추적

Orca 명령과 옵션은 설치된 Orca binary가 제공하는 version-matched guide를 따른다. 이 저장소는 Orca runtime 상태를 복제하지 않는다.

사용자 게이트는 Orca의 내부 inbox가 아니라 Feature Agent의 일반 assistant 응답으로 전달한다. Feature Agent가 분석 결과·추천 방향·결정 필요 사항을 직접 보여주고 같은 대화에서 기다린다.

### Harness Core

Harness Core는 provider-neutral 규칙과 계약이다.

- Feature Run 단계 순서
- Bootstrap·기능 ID·Branch·Worktree 정책
- Feature Agent의 단일 세션 책임 경계
- 사용자 Confirm과 Approve gate
- 역할별 모델 라우팅
- handoff와 conflict 계약
- Worktree와 branch 정책
- merge 전 충돌 분석
- 프로젝트 기능 문서 최신화
- 검증과 완료 조건

## 디렉터리 구조

    harness/
    ├─ AGENTS.md
    ├─ CLAUDE.md
    ├─ README.md
    ├─ core/
    │  ├─ agent-routing.json
    │  ├─ workflows/
    │  │  ├─ feature-run.json
    │  │  └─ integration-run.json
    │  └─ contracts/
    │     ├─ handoff.schema.json
    │     ├─ conflict-report.schema.json
    │     └─ merge-receipt.schema.json
    ├─ rules/
    │  ├─ orchestration-lifecycle.md
    │  ├─ cognitive-debt.md
    │  ├─ interaction-gates.md
    │  ├─ project-feature-documentation.md
    │  ├─ worktree-and-branch.md
    │  ├─ integration-and-conflict.md
    │  └─ completion.md
    ├─ skills-src/
    ├─ .agents/skills/
    ├─ .claude/skills/
    ├─ adapters/
    │  ├─ orca/
    │  ├─ codex/
    │  └─ claude/
    ├─ templates/
    ├─ scripts/
    └─ tests/

## Skills

스킬 이름은 Agent 이름이 아니라 수행하는 작업을 나타낸다.

| Skill | 책임 |
| --- | --- |
| personal-orchestration | 임의의 Claude/Codex 세션 진입과 자동 Bootstrap |
| feature-orchestration | Feature Run 전체 조율과 사용자 gate |
| requirements-analysis | 요구사항·현재 동작·영향 분석 |
| architecture-design | 시스템 경계·계약·데이터·설계 결정 |
| implementation | 승인된 설계의 코드·테스트·기능 문서 구현 |
| verification-and-review | diff·테스트·규칙·기능 문서 독립 검증 |
| branch-integration | merge preview·충돌 설명·통합 검증 |

논리적 원본은 skills-src에 있다. Codex는 .agents/skills를, Claude는 .claude/skills를 읽는다. 두 mirror는 항상 같은 본문이어야 한다.

## 모델 라우팅

기본 라우팅은 core/agent-routing.json에 있다.

| 역할·단계 | 기본 라우트 |
 | --- | --- |
| Feature Agent 전체 단계 | Claude Opus 5 |
| 한도·provider 장애 시 fallback | Codex Sol high |

Arena Agent leaderboard는 기본 라우팅의 근거로 사용한다. Feature Run 시작 시점의 evidence를 고정하고, 실행 중 순위가 바뀌어도 같은 기능에는 같은 기준을 사용한다. Claude의 실제 한도 초과나 provider 장애가 발생할 때만 같은 Run·Task·Worktree를 Codex가 이어받는다.

Fast는 별도 기본 route가 아니다. `core/agent-routing.json`의 `fastPolicy`와 각 route의 `fastCommand`가 명시한 경우에만 원래 프롬프트의 `fast` opt-in을 `/fast` service-tier 토글로 적용한다. `high`와 `xhigh` reasoning effort는 그대로 유지한다.

단순한 기획은 Sol medium으로 낮출 수 있고, DB·인증·동시성·아키텍처 위험이 큰 작업은 Sol xhigh로 올릴 수 있다. 기본값은 Sol high다.

## 프로젝트 기능 문서

하네스에는 기능 이력이나 실행 로그를 저장하지 않는다. 기능의 최신 구현 방식은 대상 프로젝트가 소유한다.

기본 위치:

    docs/features/<feature-id>.md

문서에는 현재 동작만 적는다.

- 기능 목적과 사용자 동작
- 처리 흐름과 상태 변화
- 규칙과 예외
- API·UI·DB·권한·외부 계약
- 영향을 받는 모듈
- 현재 동작을 확인하는 검증 방법

Agent transcript, 모델명, 단계별 handoff, 과거 결정 이력은 넣지 않는다. 과거 내용은 Git 이력으로 확인한다.

구현 단계가 이 문서를 갱신하고, 검증 단계가 코드·테스트와 문서의 일치를 확인한다. 기능 동작이 바뀌었는데 문서가 최신이 아니면 완료할 수 없다.

## Branch와 Worktree

사용자가 별도 브랜치 준비 명령을 입력할 필요는 없다. 세션이 열린 현재 checkout 브랜치의 HEAD가 기준 snapshot이 되고, 기능 요청을 받은 Harness Bootstrap이 Orca가 다음과 같은 파생 Worktree와 Feature Agent를 사용하도록 한다. 현재 base 폴더에 미커밋 변경이 있어도 그 변경은 base에 보존하고 child에는 포함하지 않는다.

    taesik
      └─ <orca-owner>/client-name-integrity-fix
          └─ Feature Agent

`orch/<feature-id>`는 Harness가 요청하는 브랜치 라벨이다. 실제 Orca 브랜치는 계정·소유자 접두사가 붙을 수 있으며, 최종 경로 요소가 Feature ID와 같고 해당 Run의 Worktree라면 정상으로 인정한다. 같은 기준 브랜치에 대한 통합은 직렬화한다. merge 직전 기준 브랜치의 최신 상태를 다시 확인한다. 충돌이 발생하면 파일별로 기준 의도, 기능 의도, 동작 영향, 해결 선택지를 보여준다. 의미가 충돌하는 선택은 사용자 승인 없이 확정하지 않는다.

## 사용 스크립트

    powershell -File scripts/sync-skills.ps1
    powershell -File scripts/verify-mirrors.ps1
    powershell -File scripts/validate-json-contracts.ps1
    powershell -File scripts/attach-project.ps1 -ProjectPath <project>
    powershell -File scripts/sync-global-harness.ps1
    powershell -File scripts/verify-worktree.ps1 -ProjectPath <project> -ExpectedBranch <branch>
    powershell -File scripts/ensure-codex-speed-policy.ps1
    powershell -File scripts/start-feature-run.ps1 -ProjectPath <project> -Intent <intent> [-FeatureTitle <title>] [-Preview]
    powershell -File scripts/route-agent.ps1 -Phase <phase> -Risk <standard|low|high> [-Fast]
    powershell -File scripts/validate-feature-transition.ps1 -CurrentState <state> -TargetPhase <phase> -RunId <id> -TaskId <id>

start-feature-run.ps1은 사용자가 매번 직접 실행하는 명령이 아니라, 일반 Claude/Codex 세션이 기능 요청을 받았을 때 내부적으로 호출하는 live Bootstrap이다. 기능 의도에서 Feature ID를 만들고 현재 checkout 브랜치를 기준으로 파생 Branch·child Worktree를 확인한 뒤 실제 Orca Run·Feature Task·단일 Feature Agent를 생성한다. `-Preview`일 때만 실행 상태를 만들지 않고 계획을 출력하며, 정상 기능 흐름에서는 사용하지 않는다. Orca 명령과 옵션은 설치된 version-matched guide를 따른다.

실행 중에는 시작 phase·Run ID·Task ID·Worktree·파일 변경 가능 여부와 routing receipt를 보고하고, 도구 묶음 전후·phase 변경·gate 대기·차단 상태를 알린다. 활성 작업이 60초를 넘으면 heartbeat를 보낸다. Run·Task·gate 상태를 확인할 수 없으면 추측하거나 일반 터미널로 대체하지 않고 멈춘다.

## 검증

    powershell -ExecutionPolicy Bypass -File scripts/validate-json-contracts.ps1
    powershell -ExecutionPolicy Bypass -File scripts/verify-mirrors.ps1
    powershell -ExecutionPolicy Bypass -File tests/harness-contract.tests.ps1

완료를 선언하기 전에 JSON 계약, skill mirror, route 출력, 문서 규칙, Worktree 정책, 기존 파일의 diff를 모두 확인한다.
