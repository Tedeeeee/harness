from __future__ import annotations

import sys

import hooklib


def main() -> int:
    hooklib.read_hook_input()
    summary = hooklib.get_implementation_summary()
    planning = hooklib.get_planning_summary()
    memory = hooklib.get_memory_summary()
    context = hooklib.build_user_prompt_submit_context(summary, planning, memory)
    sys.stdout.write(hooklib.additional_context_json("UserPromptSubmit", context))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
