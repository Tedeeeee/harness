# 09. 멀티 프로바이더 연동과 전체 아키텍처

## 목표

1. Anthropic(Claude)에만 묶여있던 하네스를 **Gemini, OpenAI도 지원**하도록 확장
2. 하네스의 **전체 구조를 정리**하고 각 모듈의 역할을 문서화

---

## 문제: API 크레딧이 떨어졌다

Anthropic API 크레딧이 소진되어 테스트를 할 수 없는 상황이 발생했다.
하네스가 Anthropic에 직결되어 있어서, 다른 LLM으로 바꿔 쓸 수가 없었다.

```python
# 변경 전 — Anthropic에 직접 의존
client = anthropic.Anthropic(api_key=config["api_key"])
response = client.messages.create(...)
```

---

## 해결: 프로바이더 추상화

### 핵심 아이디어

모든 LLM 프로바이더(Anthropic, Gemini, OpenAI)가 **같은 인터페이스**를 지키게 만든다.
query_engine은 어떤 LLM을 쓰는지 몰라도 동작한다.

```
query_engine → Provider.call() → LLMResponse
                  │
          ┌───────┼───────┐
    Anthropic   Gemini   OpenAI
```

### 정규화된 데이터 구조 (providers/base.py)

모든 프로바이더는 응답을 이 형식으로 반환한다:

```python
@dataclass
class TextBlock:       # 텍스트 응답
    type: str = "text"
    text: str = ""

@dataclass
class ToolUseBlock:    # 도구 호출 요청
    type: str = "tool_use"
    id: str = ""
    name: str = ""
    input: dict = {}

@dataclass
class LLMResponse:     # 최종 응답
    content: list      # TextBlock 또는 ToolUseBlock 리스트
    usage: Usage       # 토큰 사용량
```

### 프로바이더 인터페이스

```python
class Provider(ABC):
    @abstractmethod
    def call(self, model, max_tokens, system, messages, tools, on_text=None) -> LLMResponse:
        pass
```

- `on_text` 콜백이 있으면 스트리밍 (텍스트가 올 때마다 호출)
- `on_text`가 None이면 동기 호출 (한꺼번에 반환)

### 각 프로바이더가 하는 일

| 프로바이더 | 변환 내용 |
|-----------|----------|
| **Anthropic** | 변환 거의 없음 (원래 Anthropic 기준으로 설계됨) |
| **Gemini** | role: assistant→model, content→parts, tool 스키마 변환, tool_result→function_response |
| **OpenAI** | system prompt를 messages에 포함, tool 스키마 형식 변환, tool_result→role:tool |

### 프로바이더별 API 형식 차이

```
시스템 프롬프트:
  Anthropic → system 파라미터로 별도 전달
  Gemini    → system_instruction으로 전달
  OpenAI    → messages에 {"role": "system"} 으로 포함

도구 스키마:
  Anthropic → {"name": "bash", "input_schema": {...}}
  Gemini    → FunctionDeclaration(name="bash", parameters={...})
  OpenAI    → {"type": "function", "function": {"name": "bash", "parameters": {...}}}

도구 결과:
  Anthropic → {"role": "user", "content": [{"type": "tool_result", ...}]}
  Gemini    → Part(function_response=FunctionResponse(...))
  OpenAI    → {"role": "tool", "tool_call_id": "...", "content": "..."}
```

---

## 설정으로 프로바이더 전환

`~/.claude-harness/config.json` 하나만 바꾸면 된다:

```json
{
    "provider": "openai",
    "api_key": "sk-ant-...",
    "gemini_api_key": "AIza...",
    "openai_api_key": "sk-proj-...",
    "model": "gpt-4o-mini",
    "max_tokens": 4096
}
```

| provider 값 | 사용되는 키 | 기본 모델 |
|-------------|-----------|----------|
| `"anthropic"` | `api_key` | `claude-sonnet-4-20250514` |
| `"gemini"` | `gemini_api_key` | `gemini-2.5-flash` |
| `"openai"` | `openai_api_key` | `gpt-4o-mini` |

---

## 전체 아키텍처

### 레이어 구조

```
┌─────────────────────────────────────────────────────┐
│  1층. 진입점 (main.py)                                │
│  → 세션 복원 여부 확인 → repl 시작                      │
└──────────────────────┬──────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────┐
│  2층. REPL 루프 (repl.py)                             │
│  → 사용자 입력을 받고 분기:                              │
│     /슬래시 → 명령어 시스템                              │
│     일반 텍스트 → query_engine                         │
└──────────────────────┬──────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────┐
│  3층. 쿼리 엔진 (query_engine.py) ← 심장              │
│  → LLM ↔ Tool 반복 루프                               │
│  → 프로바이더를 통해 LLM 호출                            │
│  → 도구 요청이 오면 실행 → 결과 돌려보냄                   │
└──────────────────────┬──────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────┐
│  4층. 프로바이더 (providers/)                          │
│  → Anthropic, Gemini, OpenAI를 같은 인터페이스로 감싸   │
│  → query_engine은 어떤 LLM인지 몰라도 됨               │
└─────────────────────────────────────────────────────┘
```

### 모든 모듈과 역할

#### 1층: 진입과 초기화

| 파일 | 역할 |
|------|------|
| `main.py` | 시작점. `--resume` 옵션으로 이전 세션 복원 |
| `src/config.py` | 설정 로딩 (환경변수 > 프로젝트 > 전역 > 기본값) |
| `src/client.py` | config를 읽고 프로바이더 인스턴스 생성 |
| `src/models.py` | 모델 목록 관리, 별칭 변환 (sonnet → 전체 모델명) |

#### 2층: 사용자 인터페이스

| 파일 | 역할 |
|------|------|
| `src/repl.py` | `while True: input()` 무한 루프. 슬래시 명령어 / 일반 대화 분기 |
| `src/commands/base.py` | Command 추상 클래스 (규격) |
| `src/commands/builtin.py` | `/exit`, `/model`, `/mode`, `/help`, `/cost`, `/clear` |
| `src/commands/registry.py` | 명령어 등록소 + `find()`로 검색 |

#### 3층: 핵심 엔진

| 파일 | 역할 |
|------|------|
| `src/query_engine.py` | LLM ↔ Tool 반복 루프 (최대 50턴). 하네스의 심장 |
| `src/context.py` | 시스템 프롬프트 조립 (base.md + 모드 + git + 메모리 + CLAUDE.md) |
| `src/retry.py` | 지수 백오프 재시도 (0.5초 → 1초 → 2초 → ... 최대 60초) |
| `src/cost_tracker.py` | 입력/출력 토큰 누적 카운터 |

#### 4층: 프로바이더 (LLM 추상화)

| 파일 | 역할 |
|------|------|
| `src/providers/base.py` | Provider 추상 클래스 + 정규화 데이터 구조 |
| `src/providers/anthropic_provider.py` | Claude API 호출 + 스트리밍 |
| `src/providers/gemini_provider.py` | Gemini API 호출 + 형식 변환 |
| `src/providers/openai_provider.py` | OpenAI API 호출 + 형식 변환 |

#### 5층: 도구 시스템

| 파일 | 역할 |
|------|------|
| `src/tools/base.py` | Tool 추상 클래스 + ToolResult |
| `src/tools/registry.py` | 도구 등록소 + API 스키마 생성 |
| `src/tools/bash.py` | 셸 명령 실행 (subprocess.run) |
| `src/tools/file_read.py` | 파일 읽기 |
| `src/tools/file_write.py` | 파일 쓰기 |
| `src/tools/file_edit.py` | 파일 부분 수정 (old → new 치환) |
| `src/tools/glob_tool.py` | 파일명 패턴 검색 |
| `src/tools/grep_tool.py` | 파일 내용 검색 |
| `src/tools/web_fetch.py` | URL 내용 가져오기 |

#### 6층: 보조 시스템

| 파일 | 역할 |
|------|------|
| `src/permissions/permission_manager.py` | 도구 실행 전 사용자 승인 (y/n/a/!) |
| `src/session.py` | 대화를 JSON으로 저장/복원 |
| `src/memory.py` | 프로젝트별 기억 저장/로딩 |

#### 7층: 프롬프트 (행동 지침)

| 파일 | 역할 |
|------|------|
| `src/prompts/base.md` | 기본 역할 + 대화 흐름 (항상 로드) |
| `src/prompts/coding.md` | 코딩 모드 세부 지침 |
| `src/prompts/brainstorm.md` | 브레인스토밍 모드 |
| `src/prompts/plan.md` | 계획 모드 |

### 데이터 흐름 (실제 예시)

```
사용자: "계산기 만들어줘"
  │
  ▼
repl.py: messages에 {"role": "user", "content": "계산기 만들어줘"} 추가
  │
  ▼
query_engine: provider.call(system_prompt + messages + tools)
  │
  ▼
provider: OpenAI API 호출 → 응답을 LLMResponse로 변환
  │
  ▼
query_engine: 응답에 tool_use(file_write) 있음
  │
  ▼
permission: "file_write 실행할까요?" → 사용자 허용
  │
  ▼
file_write.execute() → 파일 생성됨
  │
  ▼
query_engine: 결과를 messages에 추가 → 다시 provider.call()
  │
  ▼
provider: "완성했습니다!" (텍스트만)
  │
  ▼
query_engine: 도구 요청 없음 → return → repl로 복귀
  │
  ▼
repl.py: "나 > " (다음 입력 대기)
```

---

## 변경된 파일

| 파일 | 변경 내용 |
|------|-----------|
| `src/providers/__init__.py` | 새로 생성 — 프로바이더 팩토리 함수 |
| `src/providers/base.py` | 새로 생성 — Provider 추상 클래스 + 정규화 타입 |
| `src/providers/anthropic_provider.py` | 새로 생성 — Anthropic 프로바이더 |
| `src/providers/gemini_provider.py` | 새로 생성 — Gemini 프로바이더 |
| `src/providers/openai_provider.py` | 새로 생성 — OpenAI 프로바이더 |
| `src/client.py` | 리팩토링 — 프로바이더 팩토리 사용 |
| `src/config.py` | gemini_api_key, openai_api_key, provider 설정 추가 |
| `src/models.py` | Gemini 모델 목록 추가 |
| `src/query_engine.py` | client 직접 호출 → provider.call() 사용 |
| `src/repl.py` | 프로바이더 표시 추가 |

---

## 배운 것

1. **추상화의 가치** — 프로바이더를 추상화하면 LLM을 교체해도 핵심 코드(query_engine)를 건드릴 필요가 없다
2. **API마다 형식이 다르다** — 시스템 프롬프트, 도구 스키마, 도구 결과 형식이 전부 다르다. 프로바이더가 이 차이를 흡수한다
3. **설정 하나로 전환** — config.json의 `provider` 값만 바꾸면 Anthropic ↔ Gemini ↔ OpenAI 전환 가능
4. **무료 API의 한계** — Gemini 무료 티어는 일일 요청 수가 제한적. 실제 개발에는 유료 API가 현실적이다
5. **프로바이더 독립성이 곧 생존력** — 한 API가 다운되거나 크레딧이 떨어져도 다른 프로바이더로 즉시 전환 가능
