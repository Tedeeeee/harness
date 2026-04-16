from __future__ import annotations

import sys

import hooklib


def main() -> int:
    hooklib.read_hook_input()
    summary = hooklib.get_implementation_summary()
    reason = hooklib.get_stop_guard_reason(summary)
    if reason:
        sys.stdout.write(hooklib.block_decision_json(reason))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
