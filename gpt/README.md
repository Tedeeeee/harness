# gpt

LLM, 하네스, 에이전트 구조를 직접 구현하고 학습 내용을 정리하는 프로젝트입니다.

이 저장소는 `Claude Code`와 비슷한 형태의 하네스를 클린룸 방식으로 천천히 만들어보는 것을 목표로 합니다.  
한 번에 큰 시스템을 만들기보다, 가장 작은 실행 루프부터 시작해서 단계별 문서와 코드로 확장합니다.

## 현재 구현 단계

현재는 `05. 세션 별 저장 추가` 단계까지 진행했습니다.

현재 가능한 것:

- CLI에서 단일 프롬프트를 한 번 실행할 수 있습니다.
- 인자 없이 실행하면 REPL 모드로 진입합니다.
- REPL 응답은 스트리밍처럼 바로 출력됩니다.
- 같은 REPL 세션 안에서는 이전 user/assistant 대화를 기억합니다.
- REPL 종료 후 다시 실행해도 같은 세션을 이어갈 수 있습니다.
- `--session <이름>` 플래그로 서로 다른 세션을 분리할 수 있습니다.
- `exit` 또는 `quit`로 REPL을 종료할 수 있습니다.

아직 없는 기능:

- 세션 목록 조회/삭제
- 파일/셸 같은 도구 호출
- 권한 정책과 검증 계층
- 멀티 에이전트

## 실행 방법

### 1. 의존성 설치

```bash
npm install
```

### 2. 환경 변수 설정

`.env.example`을 참고해서 프로젝트 루트에 `.env` 파일을 만들고 아래 값을 넣습니다.

```env
ANTHROPIC_API_KEY=your_anthropic_api_key_here
ANTHROPIC_MODEL=claude-sonnet-4-20250514
```

### 3. 단일 프롬프트 실행

```bash
npm run dev -- "안녕하세요. 한 줄로 자기소개를 해주세요."
```

### 4. 기본 세션 REPL 실행

```bash
npm run dev
```

### 5. 이름 있는 세션 REPL 실행

```bash
npm run dev -- --session bugfix-chat
```

이렇게 실행하면 `data/sessions/bugfix-chat.json`에 대화 이력이 저장되고, 다음 실행에서도 이어집니다.

## 예시

### 기본 REPL

```text
REPL 모드입니다. 종료하려면 exit 또는 quit를 입력하세요.
세션 "default"을 시작합니다.
> Hello
...스트리밍 응답...
> What was my previous message?
Your previous message was "Hello".
> quit
REPL을 종료합니다.
```

### 세션 분리

```bash
npm run dev -- --session alpha
npm run dev -- --session beta
```

위 두 세션은 서로 다른 대화창처럼 동작합니다.

## 빌드와 테스트

### 빌드

```bash
npm run build
```

### 배포용 실행

```bash
npm run start
```

### 테스트

```bash
npm test
```

## 문서 구조

단계별 문서는 `docs/steps/` 아래에 정리합니다.

- `00-harness-overview.md`: 하네스의 정의와 전체 흐름
- `01-single-call-cli.md`: Anthropic 단일 호출 CLI
- `02-streaming-output.md`: 스트리밍 출력 추가
- `03-repl-loop.md`: REPL 루프 추가
- `04-session-history.md`: 세션 내 대화 이력 추가
- `05-session-persistence.md`: 세션 별 저장 추가

각 단계 문서에는 아래 내용을 통합해서 기록합니다.

- 이번 단계의 목표
- 왜 이 단계가 필요한지
- 구현 방향
- 실제 구현 내용
- 검증 결과
- 다음 단계 후보

## 다음 목표

다음으로 확장할 후보는 아래와 같습니다.

1. 도구 호출 기초 추가
2. 세션 목록/전환 UX 보강
3. 권한과 검증 계층 보강
