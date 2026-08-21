# Personal Orchestration Harness

개인 개발 프로젝트에 붙여 사용하는 AI 오케스트레이션 하네스다. 이 저장소의 목적은 특정 모델을 고정하는 것이 아니라, Codex와 Claude가 같은 개발 원칙·인지부채 방지 규칙·사용자 게이트를 따르도록 만드는 것이다.

## 핵심 목표

하네스는 기능 요청 하나를 하나의 `Feature Orchestration` 실행으로 관리한다.

```text
사용자 기능 요청
    ↓
Feature Orchestrator
    ├─ Requirements & Impact
    ├─ Architecture & Design
    ├─ Implementation
    └─ Verification & Review
```

각 단계는 결과만 넘기지 않는다. 무엇을 이해했는지, 왜 그렇게 판단했는지, 어디에 영향을 주는지, 사용자의 결정이 필요한지를 설명한다. 사용자가 중요한 목적·구조·영향을 이해하지 못한 상태에서는 다음 단계로 진행하지 않는다.

## 기본 운영 리듬

처음에는 대부분의 단계에서 사용자 의견을 묻는다. 반복적으로 안전하다고 확인된 구간만 나중에 자동화한다.

| 게이트 | 의미 | 예시 |
| --- | --- | --- |
| Inform | 설명 후 진행 | 이미 정해진 패턴의 국소 수정 |
| Confirm | 질문에 답한 뒤 진행 | 요구사항이나 영향 범위가 애매함 |
| Approve | 명시적 승인 후 진행 | 아키텍처·DB·권한·외부 계약 결정 |
| Stop | 사용자 판단 전 중단 | 근거 충돌·검증 실패·범위 초과 |

## 디렉터리 구조

```text
harness/
├─ AGENTS.md                         # Codex 진입점
├─ CLAUDE.md                         # Claude 진입점
├─ README.md                         # 사람이 읽는 구조·사용 설명서
│
├─ rules/                            # 모든 오케스트레이션이 지키는 공통 규칙
│  ├─ orchestration-lifecycle.md
│  ├─ cognitive-debt.md
│  ├─ interaction-gates.md
│  └─ completion.md
│
├─ skills-src/                       # 스킬의 논리적 원본
│  ├─ feature-orchestrator/
│  ├─ requirements-impact/
│  ├─ architecture-design/
│  ├─ implementation/
│  └─ verification-review/
│
├─ .agents/skills/                   # Codex가 검색하는 native 경로
├─ .claude/skills/                   # Claude가 검색하는 native 경로
│
├─ adapters/                         # 도구별 연결 차이
│  ├─ codex/README.md
│  └─ claude/README.md
│
├─ templates/                        # 단계별 최소 증거 양식
│  ├─ phase-report.md
│  ├─ decision-card.md
│  ├─ implementation-start.md
│  └─ completion-receipt.md
│
├─ scripts/                          # 설치·연결·미러 검증 도구
│  ├─ sync-skills.ps1
│  └─ verify-mirrors.ps1
│
└─ tests/                            # 하네스 자체의 계약 검증
   └─ harness-contract.tests.ps1
```

## rules와 skills의 차이

`rules/`는 모든 역할이 지켜야 하는 상위 원칙이다. 인지부채를 어떻게 방지할지, 언제 질문·승인·중단할지, 무엇을 완료로 볼지를 정의한다.

`skills-src/`는 각 역할이 맡은 작업을 수행하는 방법이다.

| Skill | 책임 |
| --- | --- |
| `feature-orchestrator` | 기능 실행 상태를 소유하고 사용자와 대화하며 다음 단계를 조율 |
| `requirements-impact` | 요구사항, 기존 구조, 흐름, 영향 범위와 불확실성 파악 |
| `architecture-design` | 설계안, 대안, 책임 경계, 계약, 트레이드오프 설명 |
| `implementation` | 승인된 범위 안에서 코드와 테스트 구현 |
| `verification-review` | diff, 테스트, 규칙, 남은 위험과 완료 조건 검토 |

하위 skill은 독립적으로 사용자의 큰 결정을 확정하지 않는다. 각 결과는 근거·제안·미결정 질문·다음 게이트를 포함해 `feature-orchestrator`에게 반환한다.

## Codex와 Claude 지원

하나의 skill을 논리적 원본으로 관리하고, 각 도구가 자동으로 찾는 위치에 같은 내용을 둔다.

```text
skills-src/<skill>/SKILL.md
        ├─> .agents/skills/<skill>/SKILL.md   # Codex
        └─> .claude/skills/<skill>/SKILL.md   # Claude
```

두 native 파일은 같은 내용이어야 한다. `scripts/sync-skills.ps1`가 원본을 반영하고, `scripts/verify-mirrors.ps1`가 차이를 검사한다. Codex·Claude만의 실행 차이는 `adapters/`에 둔다. 공통 skill 본문 안에서 도구별 규칙을 갈라놓지 않는다.

## 프로젝트에 붙이는 방식

하네스는 프로젝트의 도메인 규칙을 소유하지 않는다. 프로젝트의 `AGENTS.md`, `CLAUDE.md`, 코드, 테스트가 프로젝트 사실의 원본이다. 연결 도구가 추가되면 다음 조합으로 동작한다.

```text
하네스 공통 rules + skills
        +
대상 프로젝트의 규칙·코드·테스트
        ↓
프로젝트별 Feature Orchestration
```

프로젝트를 연결할 때 기존 프로젝트 skill이나 규칙을 덮어쓰지 않는다. 연결·해제 방식은 아직 v0에서 명시적으로 확정하지 않고, 실제 `law-erp` 연결 작업 전에 별도 설계한다.

## 현재 범위에 포함하지 않는 것

- 기능마다 장문의 문서를 강제하는 `docs-first` 운영
- 가짜 `scenarios/` 실험 과제와 벤치마크 시스템
- 특정 프로젝트의 도메인·아키텍처 규칙
- 특정 모델을 영구적으로 최고 모델로 고정하는 라우팅
- 모든 파일 수정마다 인간 승인을 요구하는 세분화된 게이트

처음에는 질문과 승인을 넓게 적용하고, 실제 사용 증거를 바탕으로 안전한 반복 구간을 줄여간다.

