from __future__ import annotations

import sys

import hooklib


def main() -> int:
    hooklib.read_hook_input()
    summary = hooklib.get_implementation_summary()
    reason = hooklib.get_stop_guard_reason(summary)
    if not reason:
        planning = hooklib.get_planning_summary()
        requirements = hooklib.get_requirements_summary()
        reason = hooklib.detect_closure_mismatch(summary, planning, requirements)

    if reason:
        hooklib.append_trace(
            event_type="hook",
            actor="stop-guard",
            reason="blocked stop",
            detail=reason,
        )
        sys.stdout.write(hooklib.block_decision_json(reason))
    else:
        hooklib.append_trace(
            event_type="hook",
            actor="stop-guard",
            reason="allowed stop",
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
