# 07. 코딩 에이전트로 진화하기

## 목표

REPL 하네스를 **코딩 에이전트**로 만들기.
"계산기 프로젝트 만들어줘"라고 시키면 실제로 파일을 만들고, 테스트하고, 수정까지 해주는 에이전트.

---

## 출발점

이 시점에서 하네스에는 이미 다음이 갖춰져 있었다:

- REPL 루프 (`repl.py`)
- LLM ↔ Tool 반복 루프 (`query_engine.py`)
- 도구들: `bash`, `file_read`, `file_write`, `file_edit`, `glob`, `grep`, `web_fetch`
- 권한 관리, 세션 저장, 비용 추적

**문제:** 도구는 있는데, Claude가 **언제 어떻게 써야 하는지** 모른다.

---

## 문제 1: Claude가 도구를 안 쓴다

### 원인

시스템 프롬프트가 이것뿐이었다:

```python
"You are a helpful coding assistant."
```

이러면 Claude는 그냥 "친절한 도우미" 역할만 한다.
코드를 설명해줄 수는 있어도, 직접 파일을 만들어서 프로젝트를 구성하지는 않는다.

### 해결: 시스템 프롬프트 보강 (`context.py`)

```python
"You are a coding agent that builds software by using tools.\n"
"\n"
"## 핵심 규칙\n"
"- 사용자가 프로젝트를 요청하면, 직접 file_write로 파일을 만들고 bash로 폴더를 생성하라.\n"
"- 코드를 작성한 뒤 bash로 실행하거나 테스트해서 동작을 확인하라.\n"
"- 에러가 발생하면 에러 메시지를 읽고, file_edit으로 코드를 수정한 뒤 다시 실행하라.\n"
"- 설명만 하지 말고, 실제로 도구를 사용해서 결과물을 만들어라.\n"
"- 파일을 수정할 때는 먼저 file_read로 내용을 확인한 뒤 file_edit을 사용하라.\n"
```

**핵심 교훈:** LLM은 시스템 프롬프트에 시킨 만큼만 한다. "도구를 써라"고 명확히 지시해야 쓴다.

---

## 문제 2: 응답이 안 오는 것처럼 보인다

### 증상

사용자가 질문을 하면 화면이 멈춘다. 죽은 건지, 생각 중인 건지 알 수 없다.

### 원인

`query_engine.py`가 `client.messages.create()`를 사용하고 있었다.
이건 응답이 **전부 완성될 때까지** 아무것도 출력하지 않는다.

```python
# 변경 전 — 응답 전체를 기다렸다가 한꺼번에 출력
response = client.messages.create(...)
```

### 해결: 스트리밍으로 전환

```python
# 변경 후 — 글자가 생성되는 대로 실시간 출력
with client.messages.stream(...) as stream:
    for event in stream:
        if hasattr(event, "type") and event.type == "content_block_delta":
            if hasattr(event.delta, "text"):
                print(event.delta.text, end="", flush=True)
```

**핵심 교훈:** 도구 루프에서도 스트리밍을 써야 한다. 사용자는 "작동 중"이라는 피드백이 필요하다.

---

## 문제 3: Rate Limit (429 에러)

### 증상

```
❌ API 오류: Error code: 429 - rate_limit_error
```

### 원인

`query_engine.py`에는 재시도 로직이 없었다.
`retry.py`(`with_retry`)는 `client.py`에서만 사용되고 있었다.

### 해결: query_engine에도 재시도 적용

```python
from src.retry import with_retry

response = with_retry(lambda: client.messages.stream(...))
```

기존 `retry.py`의 지수 백오프(0.5초 → 1초 → 2초 → ... 최대 60초)가
429 에러에도 자동으로 적용된다.

**핵심 교훈:** API를 호출하는 모든 곳에 재시도 로직이 있어야 한다.

---

## 문제 4: 대화형 프로그램 실행 시 멈춤

### 증상

Claude가 계산기를 테스트하겠다며 이렇게 실행한다:

```
[도구 실행] bash({"command": "python calculator.py"})
```

그리고 영원히 멈춘다.

### 원인

`calculator.py` 안에 `input()`이 있다.
bash 도구는 `subprocess.run()`으로 실행하는데, stdin을 줄 수 없다.
`input()`이 사용자 입력을 기다리면서 프로그램이 영원히 멈춘다 (timeout 120초까지).

```python
# calculator.py의 문제 부분
choice = input("선택 (1-5): ")      # ← 여기서 멈춤
num1 = float(input("첫 번째 숫자: "))  # ← 여기까지 도달 못함
```

### 첫 번째 시도 (실패): echo 파이프

```
echo "1\n10\n5" | python calculator.py
```

Windows(cmd.exe)에서는 이 Linux 문법이 동작하지 않는다.

### 최종 해결: 시스템 프롬프트에 명시

```python
"- bash 도구는 사용자 입력(stdin)을 받을 수 없다. "
"  input()을 사용하는 대화형 프로그램을 직접 실행하지 마라.\n"
"- 대화형 프로그램을 테스트하려면, 함수를 import해서 호출하는 "
"  테스트 스크립트를 file_write로 만들어서 실행하라.\n"
"  예: python -c \"from calculator import add; print(add(1, 2))\"\n"
"- 현재 환경은 Windows다. cmd.exe 문법을 사용하라.\n"
```

이제 Claude는 대화형 프로그램을 직접 실행하지 않고, 함수 단위로 테스트한다:

```
python -c "from calculator import add; print(add(1, 2))"
```

**핵심 교훈:** LLM 에이전트는 환경의 제약을 모른다. 시스템 프롬프트에 명시해줘야 한다.

---

## 변경된 파일 요약

| 파일 | 변경 내용 |
|------|-----------|
| `src/context.py` | 시스템 프롬프트를 코딩 에이전트용으로 보강 |
| `src/query_engine.py` | 스트리밍 출력 + 재시도 로직 추가 |

---

## 배운 것

1. **시스템 프롬프트가 곧 에이전트의 능력이다** — 도구가 있어도 쓰라고 안 하면 안 쓴다
2. **스트리밍은 선택이 아니라 필수다** — 사용자에게 피드백 없는 대기는 "고장"과 구분이 안 된다
3. **재시도는 모든 API 호출에 필요하다** — 한 곳만 빠져도 그 경로에서 터진다
4. **환경 제약을 프롬프트에 알려줘야 한다** — stdin 불가, Windows 등 LLM이 모르는 것들
