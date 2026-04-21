from __future__ import annotations

import sys

import hooklib


def main() -> int:
    payload = hooklib.read_hook_input()
    summary = hooklib.get_implementation_summary()
    planning = hooklib.get_planning_summary()
    memory = hooklib.get_memory_summary()
    context = hooklib.build_user_prompt_submit_context(summary, planning, memory)

    prompt_text = ""
    if isinstance(payload, dict):
        prompt_text = str(payload.get("prompt") or payload.get("user_prompt") or "")

    interrupt = hooklib.detect_interrupt(prompt_text, summary)

    state_reason = (
        f"status={summary.current_status or 'none'}, "
        f"step={summary.current_step or 'none'}"
    )
    if interrupt:
        state_reason = f"interrupt detected; {state_reason}"
        context = (
            context
            + " Interrupt keyword detected in the new prompt while implementation is active. "
            "Before handling the new request, transition implementation-state.Current Status to "
            "'interrupted_by_user', fill the 'User Interruption' section "
            "(Original Step, Original Status, Request Summary, Handling Status=pending, "
            "Resume Target Step=Original Step), then handle the request. After handling, "
            "reset the User Interruption section and restore the Original Status/Step."
        )

    hooklib.append_trace(
        event_type="hook",
        actor="user-prompt-submit",
        reason=state_reason,
    )

    sys.stdout.write(hooklib.additional_context_json("UserPromptSubmit", context))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
