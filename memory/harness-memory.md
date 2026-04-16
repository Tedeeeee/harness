# 하네스 메모리

## 안정된 선호

- 구현 단계에서는 routine approval을 반복해서 묻지 않는다.
- blocked 상태에서는 사용자에게 정확히 하나의 unblock 질문만 한다.

## 확인된 기본값

- canonical harness는 저장소 루트 하나로 운영한다.
- runtime hook 스크립트는 `hooks/`에 두고 `.claude/settings.json`은 wiring만 담당한다.
- docs-first, step-gated execution, evidence-before-completion을 기본 원칙으로 사용한다.

## 작업 패턴

- 새 세션이나 새 프롬프트에서는 `prompt`만 보지 말고 `docs` 상태를 함께 읽는다.
- planning이 끝난 뒤 implementation은 blocker가 없으면 자동 진행한다.

## 반복된 차단 패턴

- Windows 터미널에서 한국어 출력이 깨질 수 있다.
