# Harness Research

> 마지막 업데이트: 2026-04-22

## 개요

이 저장소는 코드 구현 자체보다도, 문서 상태를 source of truth로 삼아 planning, execution, verification을 단계적으로 운영하는 docs-first 하네스다. 루트의 `docs/`, `hooks/`, `skills/`, `templates/`가 운영 프레임워크를 담당하고, `experiments/moyza-discovery/`는 그 하네스로 실제 구현한 Next.js 기반 모바일 웹 실험 앱이다.

현재 상태는 Moyza Discovery App 리스킨 프로젝트의 planning과 implementation이 모두 종료된 상태이며, 문서상 다음 공식 액션은 retrospective뿐이다.

## 기술 스택

- **런타임/언어**: Python 3 계열(훅), Node.js + TypeScript
- **프레임워크**: Next.js 15 App Router, React 19
- **테스트**: Vitest, Testing Library, Playwright
- **데이터 저장**: DB 없음, TypeScript 정적 시드 데이터
- **운영 구조**: docs-first state machine, Claude hook wiring, skill-driven workflow

## 프로젝트 구조 한눈에 보기

- `docs/`: 요구사항, 기술 접근, 계획, 구현 상태, 검증 증거를 저장하는 live 상태 문서
- `hooks/`: 세션 시작/프롬프트 제출/중단 시점에 문서를 읽어 다음 행동을 유도하는 Python 훅
- `skills/`: planner, executor, verifier 역할별 운영 규칙
- `templates/`: 상태 문서 양식
- `memory/`: 하네스 공통 기억과 프로젝트별 장기 메모
- `experiments/moyza-discovery/`: 실제 산출물인 모바일 스트리밍 탐색 앱

## 세부 문서 안내

| 문서 | 내용 | 언제 읽나 |
|------|------|-----------|
| [architecture.md](./architecture.md) | 저장소 구조, 하네스와 실험 앱의 계층 분리 | 전체 구조를 먼저 잡아야 할 때 |
| [flow.md](./flow.md) | 사용자 요청부터 verification까지의 상태 흐름 | 현재 작업이 어느 단계인지 추적할 때 |
| [modules.md](./modules.md) | 핵심 모듈과 역할, 서로의 연결점 | 특정 영역을 수정할 파일을 찾을 때 |
| [file-map.md](./file-map.md) | 핵심 파일 목록과 책임 | 빠르게 진입 파일을 찾고 싶을 때 |
| [conventions.md](./conventions.md) | 문서 규약, 코드 패턴, 테스트 관례 | 새 코드나 문서를 추가할 때 |
| [data-model.md](./data-model.md) | 정적 시드 데이터 구조와 환경 변수 계약 | 데이터/환경 설정을 바꿀 때 |
| [changelog.md](./changelog.md) | 최근 작업 흐름과 연구 문서 추가 이력 | 왜 현재 상태가 되었는지 볼 때 |
| [roadmap.md](./roadmap.md) | 남은 공식 후속 작업과 기술 부채 | 다음 액션을 잡아야 할 때 |

## 핵심 포인트

- 이 저장소의 1차 source of truth는 대화가 아니라 `docs/` 아래 상태 문서다.
- `hooks/hooklib.py`가 implementation/planning/requirements/memory 상태를 읽는 핵심 집약 지점이다.
- `experiments/moyza-discovery/`는 API 없는 정적 시드 기반 Next.js 앱이며, 하네스 결과물 예시 역할을 한다.
- 프로젝트 문서상 구현은 완료되었고 `docs/implementation/implementation-state.md`의 `Current Status`는 `done`이다.
- `docs/verification/evidence/`에 step별 로그와 스크린샷이 축적되어 있어 “완료 주장”보다 “증거 기반 종료”가 우선된다.
