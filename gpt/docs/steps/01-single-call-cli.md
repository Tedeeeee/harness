# 01. TypeScript Anthropic 단일 호출 CLI

## 이번 단계의 목표

클린룸 하네스를 한 번에 크게 만들지 않고, 가장 작은 실행 루프부터 구현한다.

이번 단계의 목표는 다음 한 줄로 정리할 수 있다.

**CLI에서 프롬프트를 입력받아 Anthropic API에 한 번 요청하고, 응답을 출력하는 최소 하네스를 만든다.**

즉 아직은 Claude Code 전체를 따라가는 것이 아니라, 이후 모든 기능의 기반이 되는 최소 루프를 먼저 증명하는 단계다.

```text
입력 -> 설정 로드 -> 모델 호출 -> 출력
```

## 왜 이 단계부터 시작하는가

하네스는 결국 모델을 실제로 일하게 만드는 실행 구조다.  
그렇기 때문에 가장 먼저 확인해야 하는 것은 정말 모델을 호출해서 원하는 형태로 결과를 받을 수 있는가이다.

이 단계가 안정적으로 동작해야 이후에 다음 기능을 안전하게 추가할 수 있다.

- 스트리밍 출력
- REPL 루프
- 대화 이력
- 도구 호출
- 세션 저장
- 검증 계층
- 멀티 에이전트 분리

## 이번 단계의 범위

### 포함

- TypeScript + Node.js 프로젝트 구성
- Anthropic API 연동
- CLI에서 1회성 프롬프트 실행
- 환경 변수를 통한 API 키 로드
- 입력 누락, API 키 누락에 대한 오류 처리

### 제외

- REPL 루프
- 스트리밍 출력
- 대화 이력
- 도구 호출
- 세션 저장
- 멀티 에이전트

## 구현 방향

이번 단계는 단일 파일 스크립트로 끝내지 않고, 아주 얇게 구조를 나눈다.  
이유는 지금은 작게 시작하되, 다음 단계에서 구조를 다시 전부 뜯지 않기 위해서다.

책임은 아래처럼 나눈다.

1. **CLI 진입점**
   - 명령줄 인자를 읽는다.
   - 프롬프트가 없으면 사용법을 출력한다.
   - 설정 로더와 Anthropic 호출기를 연결한다.

2. **설정 로더**
   - 환경 변수를 읽는다.
   - API 키 존재 여부를 확인한다.
   - 모델명을 포함한 설정 객체를 반환한다.

3. **Anthropic 클라이언트 래퍼**
   - 프롬프트를 입력받아 Anthropic Messages API를 호출한다.
   - 응답에서 텍스트를 추출해 반환한다.

## 파일 구조

```text
C:\study\gpt
  docs/
    steps/
      00-harness-overview.md
      01-single-call-cli.md
  src/
    cli.ts
    lib/
      anthropic.ts
      config.ts
  package.json
  tsconfig.json
  .gitignore
  .env.example
```

## 실제로 추가한 파일

- `package.json`
- `package-lock.json`
- `tsconfig.json`
- `.gitignore`
- `.env.example`
- `src/cli.ts`
- `src/lib/config.ts`
- `src/lib/anthropic.ts`

## 핵심 구현 내용

### 1. CLI 진입점

`src/cli.ts`는 다음 역할을 맡는다.

- CLI 인자를 하나의 프롬프트 문자열로 결합
- 프롬프트가 없으면 사용법 출력
- 설정 로드
- Anthropic 호출
- 결과 출력
- 최상위 오류 처리

### 2. 설정 로더

`src/lib/config.ts`는 다음 역할을 맡는다.

- `.env` 파일 로드
- `ANTHROPIC_API_KEY` 읽기
- `ANTHROPIC_MODEL` 읽기
- API 키가 없으면 친절한 오류를 발생

기본 모델명은 아래 값을 사용한다.

```text
claude-sonnet-4-20250514
```

### 3. Anthropic 호출기

`src/lib/anthropic.ts`는 다음 역할을 맡는다.

- Anthropic SDK 클라이언트 생성
- Messages API 호출
- 응답에서 텍스트 블록만 추출
- 텍스트가 없으면 오류 처리
- API 오류를 이해하기 쉬운 메시지로 감싸기

## 실행 방법

### 개발 모드

```bash
npm run dev -- "안녕하세요. 한 줄로 자기소개를 해주세요."
```

### 빌드

```bash
npm run build
```

### 빌드 후 실행

```bash
npm run start -- "안녕하세요. 한 줄로 자기소개를 해주세요."
```

## 검증 결과

이번 단계에서는 수동 검증을 먼저 수행했다.

### 1. 빌드 확인

실행:

```bash
npm run build
```

결과:

- TypeScript 빌드 성공

### 2. 프롬프트 누락 확인

실행:

```bash
npm run dev --
```

결과:

- `사용법: npm run dev -- "질문 또는 프롬프트"` 출력 확인

### 3. API 키 누락 확인

실행:

```bash
npm run dev -- "안녕"
```

결과:

- `ANTHROPIC_API_KEY 환경 변수가 없습니다. .env 파일을 만들고 API 키를 설정해주세요.` 출력 확인

### 4. 실제 API 호출 확인

실행:

```bash
npm run dev -- "안녕하세요. 한 줄로 자기소개를 해주세요."
```

결과:

- `.env`에서 API 키를 읽음
- Anthropic API 요청 성공
- 실제 응답 텍스트 출력 확인

예시 출력:

```text
안녕하세요! 저는 Anthropic에서 개발한 AI 어시스턴트 Claude로, 다양한 주제에 대해 도움을 드리고 대화를 나눌 수 있습니다.
```

## 오류 처리 원칙

이번 단계에서는 최소한 아래 오류를 분명하게 다룬다.

- 프롬프트 누락
- `ANTHROPIC_API_KEY` 누락
- Anthropic API 요청 실패
- 응답에 텍스트가 없는 경우

오류 메시지는 학습용 프로젝트에 맞게, 원인을 알기 쉽게 작성한다.

## 완료 기준

아래 조건을 모두 만족하면 이번 단계는 완료다.

- TypeScript 프로젝트가 정상 빌드된다.
- Anthropic API로 한 번의 요청을 보낼 수 있다.
- CLI에서 프롬프트를 입력받는다.
- 응답 텍스트를 출력한다.
- 프롬프트와 API 키 누락을 친절하게 처리한다.

현재 상태에서는 위 조건을 모두 충족했다.

## 다음 단계 후보

이번 단계 이후에는 아래 순서 중 하나로 확장할 수 있다.

1. 스트리밍 출력 추가
2. REPL 루프 추가
3. 대화 이력 추가

## 메모

이 프로젝트는 설계 문서와 구현 계획 문서를 따로 나누지 않고, 단계별 통합 문서를 기준으로 진행한다.  
앞으로도 학습과 구현 흐름을 단순하게 유지하기 위해 `docs/steps/` 아래에 단계별 문서를 쌓아간다.
