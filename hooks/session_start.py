from __future__ import annotations

import sys

import hooklib


def main() -> int:
    hooklib.read_hook_input()
    summary = hooklib.get_implementation_summary()
    planning = hooklib.get_planning_summary()
    memory = hooklib.get_memory_summary()
    context = hooklib.build_session_start_context(summary, planning, memory)

    state_reason = (
        f"status={summary.current_status or 'none'}, "
        f"step={summary.current_step or 'none'}"
    )
    hooklib.append_trace(
        event_type="hook",
        actor="session-start",
        reason=state_reason,
    )

    sys.stdout.write(hooklib.additional_context_json("SessionStart", context))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
