from __future__ import annotations

import json
import os
import pathlib
import re
import sys
from dataclasses import dataclass


@dataclass(frozen=True)
class ImplementationSummary:
    exists: bool
    current_step: str | None
    current_status: str | None
    next_allowed_action: str | None
    blockers: str | None
    pending_steps: list[str]
    active_steps: list[str]


@dataclass(frozen=True)
class PlanningSummary:
    exists: bool
    project: str | None
    stages: dict[str, str]


@dataclass(frozen=True)
class MemorySummary:
    has_harness_memory: bool
    has_project_memory: bool
    harness_memory: str | None
    project_memory: str | None
    combined_text: str


def read_hook_input() -> dict | list | None:
    raw = sys.stdin.read()
    if not raw.strip():
        return None
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return None


def get_project_path() -> pathlib.Path:
    env_path = os.environ.get("CLAUDE_PROJECT_DIR")
    if env_path:
        path = pathlib.Path(env_path)
        if path.exists():
            return path.resolve()
    return pathlib.Path(__file__).resolve().parent.parent


def _read_text(path: pathlib.Path) -> str | None:
    if not path.exists():
        return None
    return path.read_text(encoding="utf-8")


def _extract_field(text: str, label: str) -> str | None:
    match = re.search(rf"(?m)^- {re.escape(label)}:\s*(.+)$", text)
    return match.group(1).strip() if match else None


def _extract_section(text: str, heading: str) -> str | None:
    match = re.search(
        rf"(?ms)^## {re.escape(heading)}\s*(.*?)(?=^## |\Z)",
        text,
    )
    if not match:
        return None
    section = match.group(1).replace("\r", "").strip()
    return section or None


def get_implementation_summary(project_root: pathlib.Path | None = None) -> ImplementationSummary:
    root = project_root or get_project_path()
    text = _read_text(root / "docs" / "implementation" / "implementation-state.md")
    if not text:
        return ImplementationSummary(False, None, None, None, None, [], [])

    pending_steps: list[str] = []
    active_steps: list[str] = []
    for line in text.splitlines():
        pending = re.match(r"^\|\s*(step-\d+)\s*\|\s*[^|]+\|\s*pending\s*\|", line)
        if pending:
            pending_steps.append(pending.group(1))
            continue
        active = re.match(r"^\|\s*(step-\d+)\s*\|\s*[^|]+\|\s*in_progress\s*\|", line)
        if active:
            active_steps.append(active.group(1))

    return ImplementationSummary(
        exists=True,
        current_step=_extract_field(text, "Current Step"),
        current_status=_extract_field(text, "Current Status"),
        next_allowed_action=_extract_section(text, "Next Allowed Action"),
        blockers=_extract_section(text, "Blockers"),
        pending_steps=pending_steps,
        active_steps=active_steps,
    )


def get_planning_summary(project_root: pathlib.Path | None = None) -> PlanningSummary:
    root = project_root or get_project_path()
    text = _read_text(root / "docs" / "plans" / "planning-state.md")
    if not text:
        return PlanningSummary(False, None, {})

    stages: dict[str, str] = {}
    for line in text.splitlines():
        match = re.match(
            r"^\|\s*(requirements|technical-approach|interview|master-plan|step-docs)\s*\|\s*([^|]+)\s*\|",
            line,
        )
        if match:
            stages[match.group(1).strip()] = match.group(2).strip()

    return PlanningSummary(
        exists=True,
        project=_extract_field(text, "Project"),
        stages=stages,
    )


def get_memory_summary(project_root: pathlib.Path | None = None) -> MemorySummary:
    root = project_root or get_project_path()
    harness_memory = _read_text(root / "memory" / "harness-memory.md")
    project_memory = _read_text(root / "memory" / "project-memory.md")

    harness_memory = harness_memory.strip() if harness_memory else None
    project_memory = project_memory.strip() if project_memory else None

    parts: list[str] = []
    if harness_memory:
        parts.append(f"Harness memory:\n{harness_memory}")
    if project_memory:
        parts.append(f"Project memory:\n{project_memory}")

    return MemorySummary(
        has_harness_memory=bool(harness_memory),
        has_project_memory=bool(project_memory),
        harness_memory=harness_memory,
        project_memory=project_memory,
        combined_text="\n\n".join(parts),
    )


def additional_context_json(event_name: str, additional_context: str) -> str:
    return json.dumps(
        {
            "hookSpecificOutput": {
                "hookEventName": event_name,
                "additionalContext": additional_context,
            }
        },
        ensure_ascii=False,
        separators=(",", ":"),
    )


def block_decision_json(reason: str) -> str:
    return json.dumps(
        {"decision": "block", "reason": reason},
        ensure_ascii=False,
        separators=(",", ":"),
    )


def _is_blocked(summary: ImplementationSummary) -> bool:
    status = (summary.current_status or "").strip().lower()
    blockers = (summary.blockers or "").strip().lower()
    return bool(status == "blocked" or (blockers and blockers not in {"none", "- none"}))


def build_session_start_context(
    summary: ImplementationSummary,
    planning: PlanningSummary,
    memory: MemorySummary,
) -> str:
    is_done = summary.current_status == "done" or summary.current_step == "completed"
    memory_line = f"Read memory before acting:\n{memory.combined_text}\n" if memory.combined_text else ""

    if not summary.exists and planning.exists:
        planning_stages = ", ".join(f"{key}: {value}" for key, value in planning.stages.items())
        return (
            f"self-harness project detected. {memory_line}"
            f"Planning is in progress. Stages: {planning_stages}. "
            "Route from prompt plus planning-state. Do not jump to implementation."
        )

    if not summary.exists:
        return (
            f"self-harness project detected. No implementation or planning state exists yet. {memory_line}"
            "Route from prompt plus docs state. Start by checking docs/requirements and use "
            "route-self-harness before choosing a planning or execution skill."
        )

    if _is_blocked(summary):
        blocker_text = summary.blockers or "A blocker is recorded in implementation state."
        return (
            f"self-harness project detected. {memory_line}"
            "The harness is currently blocked. Do not continue planning or execution yet. "
            "Your next response must ask the user exactly one concise question needed to unblock the work. "
            f"Blocker context: {blocker_text}"
        )

    if is_done:
        return (
            f"self-harness project detected. {memory_line}"
            "The last recorded implementation state is complete. If the user wants new work, begin by "
            "routing from the current prompt and docs state instead of assuming implementation should continue."
        )

    next_action = summary.next_allowed_action or "Check docs/implementation/implementation-state.md for the next allowed action."
    return (
        f"self-harness project detected. {memory_line}"
        f"Recover state from docs before acting. Current step: {summary.current_step}. "
        f"Current status: {summary.current_status}. Next allowed action: {next_action} "
        "Route through route-self-harness before continuing."
    )


def build_user_prompt_submit_context(
    summary: ImplementationSummary,
    planning: PlanningSummary,
    memory: MemorySummary,
) -> str:
    if not summary.exists and not planning.exists:
        state_line = "No implementation or planning state file exists yet."
    elif planning.exists and not summary.exists:
        planning_stages = ", ".join(f"{key}: {value}" for key, value in planning.stages.items())
        state_line = f"Planning in progress. Stages: {planning_stages}."
    else:
        state_line = f"Current step: {summary.current_step}. Current status: {summary.current_status}."

    memory_line = f"Read memory before deciding the next action:\n{memory.combined_text}\n" if memory.combined_text else ""
    if _is_blocked(summary):
        blocker_text = summary.blockers or "A blocker is recorded in implementation state."
        return (
            f"This repository uses self-harness. {memory_line}"
            "The harness is currently blocked. Do not continue planning or execution yet. "
            "Read docs state first, then ask the user exactly one concise question needed to unblock the work. "
            f"Blocker context: {blocker_text}"
        )

    return (
        f"This repository uses self-harness. {memory_line}"
        "Before responding to the prompt, read docs state and route from prompt plus state, not prompt alone. "
        f"{state_line} If planning is incomplete, do not jump directly to implementation."
    )


def get_stop_guard_reason(summary: ImplementationSummary) -> str | None:
    if not summary.exists:
        return None

    status = (summary.current_status or "").lower()
    blockers = (summary.blockers or "").lower()
    next_action = (summary.next_allowed_action or "").lower()
    current_step = (summary.current_step or "").lower()

    if "verification-ready" in status or re.search(r"verify-current-step|verification", next_action):
        return "Current step is ready for verification. Run verify-current-step before stopping."

    if "blocked" in status or (blockers and blockers not in {"none", "- none"}):
        return (
            "Blocked work is recorded in implementation state. Do not stop. Ask the user exactly one concise "
            "question needed to unblock the work, then continue through implementation-blocker or planner logic."
        )

    all_done = (
        status == "done"
        or current_step == "completed"
        or (not summary.pending_steps and not summary.active_steps and re.search(r"\bnone\b", next_action))
    )
    if all_done:
        return None

    if summary.pending_steps and not summary.active_steps:
        next_step = summary.pending_steps[0]
        return f"A pending step remains with no active step. Run implementation-start to activate {next_step} before stopping."

    if "in_progress" in status and next_action:
        return "Implementation is still in progress. Continue the active step or move it to verification-ready before stopping."

    return None
