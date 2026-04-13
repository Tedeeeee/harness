# 08. 프롬프트 모듈화 — 시스템 프롬프트 분리와 모드 시스템

## 목표

하나의 거대한 시스템 프롬프트를 **모듈별 파일로 분리**하고,
상황에 따라 **필요한 프롬프트만 로드**하는 모드 시스템을 만든다.

---

## 왜 이게 필요한가?

### 문제: 시스템 프롬프트가 점점 비대해진다

07단계에서 코딩 에이전트를 만들면서 시스템 프롬프트에 다음을 추가했다:

- 코딩 에이전트 역할 정의
- 작업 흐름 (6단계)
- 대화형 프로그램 주의사항
- Windows 환경 정보
- 한국어 응답 지시

여기에 브레인스토밍, 계획 모드까지 넣으면 프롬프트가 끝없이 커진다.

### 비대한 프롬프트의 문제

1. **토큰 비용 증가** — 매 API 호출마다 전체 프롬프트가 전송된다
2. **rate limit** — 입력 토큰이 많을수록 분당 한도에 빨리 걸린다
3. **지시 충돌** — "코드를 만들어라" + "코드를 만들지 마라(브레인스토밍)" 이 동시에 있으면 혼란
4. **유지보수 어려움** — 하나의 긴 문자열을 수정하기 어렵다

### Claude Code는 어떻게 하는가?

Claude Code(oh-my-claudecode 레포 분석 기반)는 프롬프트를 계층화한다:

```
CLAUDE.md          ← 기본 프롬프트 (항상 로드, 압축본)
agents/*.md        ← 에이전트별 개별 프롬프트
skills/*/SKILL.md  ← 모드별 프롬프트 (필요할 때만 로드)
```

사용자가 "plan" 키워드를 쓰면 plan의 SKILL.md만 주입하고,
"autopilot"이면 autopilot의 SKILL.md만 주입한다.

**핵심: 모든 지침을 항상 보내지 않고, 상황에 맞는 것만 보낸다.**

---

## 해결: 프롬프트 파일 분리

### 변경 전 (context.py에 하드코딩)

```python
parts = [
    "You are a coding agent that builds software...\n"
    "## 핵심 규칙\n"
    "- 사용자가 프로젝트를 요청하면...\n"
    "## 작업 흐름\n"
    "1. 사용자의 요청을 분석한다\n"
    # ... 계속 길어짐
]
```

### 변경 후 (파일 기반 로딩)

```
src/prompts/
  base.md          ← 기본 역할 + 환경 정보 (항상 로드)
  coding.md        ← 코딩 모드 (도구 사용, 테스트 방법)
  brainstorm.md    ← 브레인스토밍 모드 (질문 위주)
  plan.md          ← 계획 모드 (구조 설계)
```

```python
# context.py — 파일에서 프롬프트를 읽어서 조합
def get_system_context():
    parts = []
    parts.append(_load_prompt("base.md"))        # 항상
    parts.append(_load_prompt(MODES[_current_mode]))  # 모드별
    parts.append(f"Working directory: {cwd}")     # 환경
    # ... git, 메모리, CLAUDE.md 등
```

---

## 모드 시스템

### 3가지 모드

| 모드 | 파일 | 역할 |
|------|------|------|
| `coding` | `coding.md` | 도구로 직접 코드 작성/테스트 (기본값) |
| `brainstorm` | `brainstorm.md` | 질문하며 요구사항 파악, 도구 사용 안 함 |
| `plan` | `plan.md` | 프로젝트 구조/아키텍처 설계 |

### 사용법

```
/mode              → 현재 모드 확인
/mode brainstorm   → 브레인스토밍 모드로 전환
/mode plan         → 계획 모드로 전환
/mode coding       → 코딩 모드로 전환
```

### 이상적인 프로젝트 생성 흐름

```
/mode brainstorm
나 > 계산기 프로젝트 만들고 싶어
Claude > 어떤 형태의 계산기요? CLI? GUI? 웹? (질문)
나 > CLI로, 공학용 계산기
Claude > 어떤 공학 함수가 필요해요? sin, cos, log? (질문)
나 > 기본 삼각함수랑 로그

/mode plan
Claude > 이런 구조로 설계할게요:
         src/operations/basic.py — 사칙연산
         src/operations/scientific.py — 삼각함수, 로그
         src/calculator.py — 메인 루프
         tests/ — 테스트
나 > 좋아

/mode coding
Claude > (실제로 file_write, bash 등 도구를 써서 프로젝트 생성)
```

---

## 변경된 파일

| 파일 | 변경 내용 |
|------|-----------|
| `src/prompts/base.md` | 새로 생성 — 기본 역할 + 환경 정보 |
| `src/prompts/coding.md` | 새로 생성 — 코딩 모드 지침 |
| `src/prompts/brainstorm.md` | 새로 생성 — 브레인스토밍 모드 지침 |
| `src/prompts/plan.md` | 새로 생성 — 계획 모드 지침 |
| `src/context.py` | 전면 리팩토링 — 파일 기반 로딩 + 모드 전환 |
| `src/commands/builtin.py` | `ModeCommand` 추가 |
| `src/commands/registry.py` | `ModeCommand` 등록 |
| `src/repl.py` | 모드 전환 시 시스템 프롬프트 반영 + 모드 표시 |

---

## 배운 것

1. **프롬프트는 코드처럼 모듈화해야 한다** — 하나의 긴 문자열은 유지보수가 어렵다
2. **상황에 맞는 프롬프트만 로드하라** — 불필요한 지침은 토큰 낭비이고 혼란을 준다
3. **모드 전환은 시스템 프롬프트 교체일 뿐이다** — 복잡한 메커니즘이 아니라 어떤 .md를 읽느냐의 차이
4. **Claude Code도 같은 패턴을 쓴다** — SKILL.md 파일을 상황에 따라 주입하는 구조
