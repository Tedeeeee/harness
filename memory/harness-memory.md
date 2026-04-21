# 하네스 메모리

> 카테고리 범례 (phase-04):
> - `user`: 사용자 역할·목표·지식
> - `feedback`: "이렇게 하라 / 이렇게 하지 말라" 같은 작업 방식 지침
> - `project`: 프로젝트 전반 사실/결정
> - `reference`: 외부 자원을 가리키는 포인터
>
> 각 섹션 헤더 옆의 `[category]` 태그가 분류를 나타낸다.

## 안정된 선호 [feedback]

- 구현 단계에서는 routine approval을 반복해서 묻지 않는다.
- blocked 상태에서는 사용자에게 정확히 하나의 unblock 질문만 한다.
- verify-current-step이 pass로 끝나고 blocker 없이 pending step이 남아 있으면 재승인 없이 `implementation-start` → `implement-current-step`으로 이어간다.

## 확인된 기본값 [project]

- canonical harness는 저장소 루트 하나로 운영한다.
- runtime hook 스크립트는 `hooks/`에 두고 `.claude/settings.json`은 wiring만 담당한다.
- docs-first, step-gated execution, evidence-before-completion을 기본 원칙으로 사용한다.
- step 수용 기준 기본값은 "균형": 해당 step이 추가한 로직의 Vitest + Playwright 시나리오 1~3건(모바일 뷰포트 포함) + 스크린샷 1장 이상 + `docs/verification/step-xx-verification.md`에서 증거 파일 경로 링크. 본 규격으로 6 step 무재작업 확인.

## 작업 패턴 [feedback]

- 새 세션이나 새 프롬프트에서는 `prompt`만 보지 말고 `docs` 상태를 함께 읽는다.
- planning이 끝난 뒤 implementation은 blocker가 없으면 자동 진행한다.
- Playwright 기반 프로젝트는 `test:e2e:install` 스크립트에서 **device 프로파일에 맞는 브라우저**를 지정한다(iPhone 프로파일 → WebKit). chromium 기본 설치만 믿으면 E2E가 실패한다.

## 반복된 차단 패턴 [feedback]

- Windows 터미널에서 한국어 출력이 깨질 수 있다.
- Stop hook은 `docs/implementation/implementation-state.md`의 `Next Allowed Action` 필드를 `verify-current-step|verification` 정규식으로 매칭해 "아직 verify 필요"로 오판할 수 있다. verify pass 이후 다음 step 안내 문구에 `verify-current-step` 또는 `verification` 단어를 넣지 않는다(한국어 "검증"은 영향 없음).
