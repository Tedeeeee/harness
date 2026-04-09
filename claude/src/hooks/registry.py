"""
Hook 시스템 — 실행 흐름 중간에 관찰 가능한 이벤트 포인트

Phase 1 이벤트:
  - before_task: task 실행 직전
  - after_tool: 도구 실행 직후
  - on_failure: task 실패 시
  - after_task: task 완료/실패 후 공통 정리

hook 자체의 예외는 메인 흐름을 죽이지 않는다 (삼킴).
"""

import sys
from collections import defaultdict
from typing import Callable


class HookRegistry:
    """이벤트 기반 hook 등록소"""

    def __init__(self):
        self._hooks: dict[str, list[Callable]] = defaultdict(list)

    def on(self, event: str, fn: Callable) -> None:
        """이벤트에 hook 함수를 등록한다."""
        self._hooks[event].append(fn)

    def emit(self, event: str, **ctx) -> None:
        """이벤트를 발생시킨다. 등록된 모든 hook을 순서대로 호출한다."""
        for fn in self._hooks[event]:
            try:
                fn(**ctx)
            except Exception as e:
                # hook 실패는 메인 흐름을 죽이지 않는다
                print(f"  [hook 오류] {event}: {e}", file=sys.stderr)
